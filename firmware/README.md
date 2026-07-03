# firmware — ESP32 自動灌水コントローラ

ESP32 (Freenove WROOM) で土壌水分・気温・湿度を計測し、バックエンドの灌水判定に従って
リレー経由で灌水ポンプを制御するファームウェア。

## 状態

- **コード：実装済み・コンパイル検証済み**
- **実機フラッシュ・実測動作：未実施（機材入荷待ち）**

土壌水分センサーと灌水ポンプ／電磁弁が未入荷のため、実機での動作確認は保留。
配線を前提にコードは完成しており、`arduino-cli compile` は通過する。
入荷後に配線・フラッシュ・キャリブレーション（`SOIL_ADC_DRY` / `SOIL_ADC_WET`）を行う。

## 配線

| GPIO | 接続 |
|---|---|
| GPIO34 | 土壌水分センサー アナログ出力（ADC1・入力専用） |
| GPIO27 | DHT11 DATA（気温・湿度） |
| GPIO26 | リレー（灌水ポンプ／電磁弁） |

## セットアップ

```bash
cp firmware/soil_sensor/secrets.h.example firmware/soil_sensor/secrets.h
# secrets.h に Wi-Fi(2.4GHz) と SERVER_URL を設定
```

## ビルド・フラッシュ

```powershell
$cli = "E:\Arduino\resources\app\lib\backend\resources\arduino-cli.exe"

# ライブラリ
& $cli lib install "ArduinoJson" "DHT sensor library"

# コンパイル
& $cli compile --fqbn esp32:esp32:esp32 firmware/soil_sensor

# フラッシュ（BOOT押しながらRSTでダウンロードモードに入れてから）
& $cli upload --fqbn esp32:esp32:esp32 -p COM5 firmware/soil_sensor
```

## 動作フロー

1. `GET /api/session` … 署名付きセッションCookieを取得して保持
2. 土壌水分（0-100%）・気温・湿度を計測
3. `POST /api/sensor` … 計測値を送信し灌水判定を受信
4. `schedule.action == "execute_now"` のときだけリレーON（灌水実行）

バックエンドはCookieセッション方式のため、初回に取得したCookieを以降のPOSTで再送する。
`400`/`401` を受けた場合はセッション失効とみなしCookieを破棄して次回再取得する。
