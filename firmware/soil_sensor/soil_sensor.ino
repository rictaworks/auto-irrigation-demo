/*
 * soil_sensor.ino
 *
 * ESP32 (Freenove WROOM) 自動灌水デモ用ファームウェア。
 *
 * 配線:
 *   GPIO34 : 土壌水分センサー アナログ出力 (ADC1, 入力専用ピン)
 *   GPIO27 : DHT11 DATA (気温・湿度)
 *   GPIO26 : リレー (灌水ポンプ / 電磁弁)
 *
 * 動作:
 *   1. GET  /api/session   … 署名付きセッションCookieを取得して保持する
 *   2. 土壌水分(0-100%)・気温・湿度を計測
 *   3. POST /api/sensor    … 計測値を送信し灌水判定を受け取る
 *   4. schedule.action == "execute_now" のときだけリレーON(灌水実行)
 *
 * 注意:
 *   - バックエンドはCookieセッション方式のため、初回に /api/session で
 *     取得した Cookie を以降のPOSTで再送する必要がある。
 *   - 土壌水分センサー・灌水ポンプは未入荷。配線前提でコードは実装済みだが、
 *     実機フラッシュ・実測動作確認は機材入荷後に行う(コンパイル検証のみ済)。
 *
 * secrets.h.example -> secrets.h にコピーして各値を設定すること。
 */

#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include "secrets.h"

#define SOIL_PIN       34      // 土壌水分センサー アナログ入力 (ADC1)
#define DHT_PIN        27      // DHT11 DATA
#define DHT_TYPE       DHT11
#define RELAY_PIN      26      // 灌水ポンプ用リレー
#define READ_INTERVAL  10000   // ms

// 土壌水分センサーのキャリブレーション値 (実機接続時に実測して調整する)。
// 容量式センサーは 乾燥=高い / 湿潤=低い の傾向。ADCは12bit (0-4095)。
#define SOIL_ADC_DRY   3200    // 空気中(0%)相当のADC値
#define SOIL_ADC_WET   1300    // 水中(100%)相当のADC値

DHT dht(DHT_PIN, DHT_TYPE);

static bool   pumpState = false;
static String sessionCookie = "";   // "session_id=...." 形式で保持

void setupWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("WiFi connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected: " + WiFi.localIP().toString());
}

void setRelay(bool on) {
  pumpState = on;
  digitalWrite(RELAY_PIN, on ? HIGH : LOW);
}

// 土壌水分センサーの生ADC値を 0-100% に変換する。
int readSoilMoisturePct() {
  int raw = analogRead(SOIL_PIN);
  // DRY(0%) 〜 WET(100%) を線形マッピングして 0-100 にクランプ
  long pct = map(raw, SOIL_ADC_DRY, SOIL_ADC_WET, 0, 100);
  if (pct < 0)   pct = 0;
  if (pct > 100) pct = 100;
  return (int)pct;
}

// GET /api/session でCookieを取得。成功時 true。
bool ensureSession(WiFiClientSecure &client) {
  if (sessionCookie.length() > 0) return true;

  HTTPClient http;
  if (!http.begin(client, String(SERVER_URL) + "/api/session")) {
    Serial.println("session begin failed");
    return false;
  }
  const char *headerKeys[] = {"Set-Cookie"};
  http.collectHeaders(headerKeys, 1);

  int code = http.GET();
  bool ok = false;
  if (code == 200) {
    String setCookie = http.header("Set-Cookie");
    int semi = setCookie.indexOf(';');
    String cookie = (semi >= 0) ? setCookie.substring(0, semi) : setCookie;
    cookie.trim();
    if (cookie.length() > 0) {
      sessionCookie = cookie;
      Serial.println("Session acquired: " + sessionCookie.substring(0, 20) + "...");
      ok = true;
    } else {
      Serial.println("Set-Cookie header missing");
    }
  } else {
    Serial.printf("GET /api/session failed: %d\n", code);
  }
  http.end();
  return ok;
}

void setup() {
  Serial.begin(115200);
  pinMode(RELAY_PIN, OUTPUT);
  setRelay(false);
  analogReadResolution(12);   // 0-4095
  dht.begin();
  setupWiFi();
}

void loop() {
  static unsigned long lastRead = 0;
  unsigned long now = millis();
  if (now - lastRead < READ_INTERVAL) return;
  lastRead = now;

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi lost, reconnecting...");
    setupWiFi();
    return;
  }

  float humidity    = dht.readHumidity();
  float temperature = dht.readTemperature();
  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("DHT11 read error");
    return;
  }
  int soilPct = readSoilMoisturePct();

  Serial.printf("Soil: %d%%  Temp: %.1fC  Hum: %.1f%%\n",
                soilPct, temperature, humidity);

  WiFiClientSecure client;
  client.setInsecure();   // デモ用途: 証明書検証を省略

  if (!ensureSession(client)) return;

  HTTPClient http;
  if (!http.begin(client, String(SERVER_URL) + "/api/sensor")) {
    Serial.println("sensor begin failed");
    return;
  }
  http.addHeader("Content-Type", "application/json");
  http.addHeader("Cookie", sessionCookie);

  StaticJsonDocument<256> req;
  JsonObject sr = req.createNestedObject("sensor_reading");
  sr["soil_moisture_pct"] = soilPct;
  sr["rainfall_today_mm"] = 0;     // 雨量センサー未接続のため0
  sr["forecast_rain_mm"]  = 0;     // 予報連携なしのため0
  sr["temperature_c"]     = temperature;
  sr["humidity_pct"]      = humidity;
  req["contact_url"]      = "";     // ハニーポット(Botでないので空)

  String body;
  serializeJson(req, body);

  int statusCode = http.POST(body);
  if (statusCode == 201) {
    String respStr = http.getString();
    StaticJsonDocument<512> res;
    if (deserializeJson(res, respStr) == DeserializationError::Ok) {
      const char *level  = res["decision"]["level"]  | "none";
      const char *action = res["schedule"]["action"] | "skip";
      Serial.printf("Decision: level=%s action=%s\n", level, action);

      // 「今すぐ実行(execute_now)」のときだけポンプを回す
      bool shouldIrrigate = (strcmp(action, "execute_now") == 0);
      if (shouldIrrigate != pumpState) {
        setRelay(shouldIrrigate);
        Serial.printf("Pump -> %s\n", shouldIrrigate ? "ON" : "OFF");
      }
    } else {
      Serial.println("Response JSON parse error");
    }
  } else if (statusCode == 400 || statusCode == 401) {
    // セッション失効の可能性 -> 破棄して次回再取得
    Serial.printf("POST /api/sensor auth error: %d (reset session)\n", statusCode);
    sessionCookie = "";
  } else {
    Serial.printf("POST /api/sensor failed: %d\n", statusCode);
  }

  http.end();
}
