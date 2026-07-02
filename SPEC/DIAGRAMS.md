# 実装反映図（as-built）

`/auto-irrigation-demo-spec.md`（初期設計書）のASCIIアート図を、実装（`src/backend`, `src/frontend`）の内容に合わせて更新したもの。Mermaid記法で記述する（`.claude/rules/project-structure.md`）。

設計時点からの主な差分:

- カラム名 `recommended_L` → 実装では Rails 命名規約により `recommended_l`。
- `field_settings` / `sensor_readings` / `irrigation_logs` に `created_at`/`updated_at`（ActiveRecordの標準タイムスタンプ）が実装で追加されている。
- `GET /api/session`・`GET /api/field_settings`・`GET /api/sensor` が実装で追加されている（設計時点はPOST/判定系のみを想定）。ダッシュボード（`/`）は再読み込み時にこの2件のGETを並行取得して直近の判定結果を復元する。
- ハニーポットチェック（`check_honeypot!`）は各コントローラの `create` アクションでのみ呼ばれ、`show`（GET）系では呼ばれない。
- 判定ロジックの閾値・係数は `config/irrigation_rules.yml` に外部化されている（コーディング規約によりハードコード禁止のため）。
- 夜間時間帯（JST 22:00〜5:00）の「今すぐ灌水」判定は `emergency_confirm` となり、フロントエンドの `ConfirmModal` で確認を挟んでから記録する（ネイティブ`confirm()`は使用禁止のため独自コンポーネント）。

---

## 1. ER図

```mermaid
erDiagram
    sessions ||--o{ field_settings : "has"
    sessions ||--o{ sensor_readings : "has"
    sessions ||--o{ irrigation_logs : "has"

    sessions {
        string id PK "UUID v4"
        datetime last_active_at
        datetime created_at
        datetime updated_at
    }
    field_settings {
        integer id PK
        string session_id FK
        float area_m2
        string soil_type "sandy_loam / loam / clay"
        datetime created_at
        datetime updated_at
    }
    sensor_readings {
        integer id PK
        string session_id FK
        float soil_moisture_pct
        float rainfall_today_mm
        float forecast_rain_mm
        float temperature_c
        float humidity_pct
        datetime recorded_at
        datetime created_at
        datetime updated_at
    }
    irrigation_logs {
        integer id PK
        string session_id FK
        string decision "immediate/recommended/watch/none"
        float soil_moisture
        float weather_coeff
        float total_score
        float recommended_l
        string action_taken
        datetime executed_at
        datetime created_at
        datetime updated_at
    }
```

`soil_types`・`irrigation_levels` はテーブル化せず、`FieldSetting::SOIL_TYPES` / `IrrigationLog::DECISIONS`（Rubyの配列定数）およびUI表示文言 `messages/*.json` として実装されている（設計書の「マスタデータ定義」に対応）。

---

## 2. DFD（データフロー図）

```mermaid
flowchart TD
    User([ユーザー])
    Scheduler([Scheduler JST03:00])

    subgraph API["Rails API (Api::BaseController)"]
        P0[/"セッション確認・自動発行"/]
        P1[/"POST /api/sensor 受信"/]
        P2{Botチェック<br/>ハニーポット}
        P3[土壌水分評価<br/>SoilMoistureEvaluator]
        P4[天気条件評価<br/>WeatherEvaluator]
        P5[灌水要否判定<br/>IrrigationDecisionEngine#calculate_need]
        P6[推奨水量算出<br/>#calculate_volume]
        P7[スケジューリング<br/>#schedule]
        P8[/"POST /api/irrigate 受信"/]
        P9[日次リセット<br/>DailyResetter]
    end

    D1[(sessions)]
    D2[(field_settings)]
    D3[(sensor_readings)]
    D4[(irrigation_logs)]

    User -- "画面アクセス" --> P0
    P0 <-- "検索/発行" --> D1
    P0 -- "署名付きCookie発行" --> User

    User -- "センサー値入力" --> P1
    P1 --> P2
    P2 -- "Botと判定" --> Abort[["処理中断（200 OKのみ返却）"]]
    P2 -- "人間" --> P3
    P3 --> P4
    P4 --> P5
    P5 --> P6
    D2 -. "圃場設定(面積・土壌種別)" .-> P6
    P6 --> P7
    P7 -- "sensor_readings保存" --> D3
    P7 -- "判定結果" --> User

    User -- "灌水を記録する" --> P8
    P8 --> P2b{Botチェック}
    P2b -- "人間" --> D4
    D4 -- "履歴一覧" --> User

    Scheduler -- "JST 03:00" --> P9
    P9 -- "rainfall_today_mmを全件0に更新" --> D3
```

---

## 3. シーケンス図

### 3.1 セッション自動発行（全APIリクエスト共通・`Api::BaseController#ensure_session!`）

```mermaid
sequenceDiagram
    participant U as ユーザー
    participant FE as Next.js
    participant API as Rails API
    participant DB as SQLite

    U->>FE: 画面アクセス
    FE->>API: 任意のAPIリクエスト（署名付きCookie同梱）
    alt Cookieが有効なセッションを指す
        API->>DB: Session.find(id)
        DB-->>API: session
        API->>DB: last_active_at 更新
    else Cookieが無い/無効
        API->>API: SecureRandom.uuid で新規発行
        API->>DB: Session.create!
        API->>FE: Set-Cookie（署名付き・HttpOnly・SameSite=Strict）
    end
    API-->>FE: 通常のレスポンス
```

### 3.2 メインフロー（センサー入力 → 灌水判定 → 記録）

```mermaid
sequenceDiagram
    participant U as ユーザー
    participant FE as Next.js
    participant API as Rails API
    participant DB as SQLite

    U->>FE: /sensor で数値入力し送信
    FE->>API: POST /api/sensor { sensor_reading, contact_url(空) }
    API->>API: check_honeypot!（contact_urlに値があればBot→200 OKのみ返し中断）
    API->>DB: sensor_readings.create!
    API->>API: SoilMoistureEvaluator#evaluate
    API->>API: WeatherEvaluator#evaluate
    API->>API: IrrigationDecisionEngine#calculate_need
    API->>DB: field_settings（直近1件）取得
    API->>API: #calculate_volume / #schedule
    API-->>FE: 判定結果（decision/volume/schedule等）
    FE-->>U: ダッシュボードへ遷移し結果表示

    Note over U,FE: 判定 decision.level が "none" 以外なら「灌水を記録する」を活性化

    U->>FE: 「灌水を記録する」クリック
    alt schedule.action == "emergency_confirm"（夜間22:00-5:00）
        FE-->>U: ConfirmModal表示（独自コンポーネント、confirm()不使用）
        U->>FE: 実行するを選択
    end
    FE->>API: POST /api/irrigate { irrigation_log, contact_url(空) }
    API->>API: check_honeypot!
    API->>DB: irrigation_logs.create!
    API-->>FE: 記録結果
    FE-->>U: /history へ遷移
```

### 3.3 ダッシュボード再読み込み（設計時点になかった追加フロー）

```mermaid
sequenceDiagram
    participant U as ユーザー
    participant FE as Next.js (/ ダッシュボード)
    participant API as Rails API
    participant DB as SQLite

    U->>FE: ダッシュボードを開く/再読み込み
    par 並行取得
        FE->>API: GET /api/sensor
        API->>DB: sensor_readings 直近1件を現在時刻で再評価
        API-->>FE: 直近の判定結果（無ければnull）
    and
        FE->>API: GET /api/field_settings
        API->>DB: field_settings 直近1件
        API-->>FE: 圃場設定（無ければnull）
    end
    alt 判定結果がnull
        FE-->>U: 「まだセンサーデータが入力されていません」+ センサー入力へのCTA
    else 判定結果あり
        FE-->>U: 判定結果・推奨水量・推奨アクションを表示
    end
```

### 3.4 日次リセットフロー

```mermaid
sequenceDiagram
    participant S as whenever(cron) JST03:00
    participant Task as rake irrigation:daily_reset
    participant Resetter as DailyResetter
    participant DB as SQLite

    S->>Task: 起動
    Task->>Resetter: execute_reset
    Resetter->>Resetter: trace_id発行・開始ログ
    Resetter->>DB: SensorReading.update_all(rainfall_today_mm: 0)
    alt 成功
        Resetter->>Resetter: 完了ログ
    else ActiveRecordError
        Resetter->>Resetter: エラーログ後re-raise
    end
```

---

## 4. クラス図

```mermaid
classDiagram
    class IrrigationRules {
        <<module>>
        +load() Hash
    }
    class HoneypotConfig {
        <<module>>
        +load() Hash
    }

    class SoilMoistureEvaluator {
        -thresholds: Array
        +validate(moisture) Boolean
        +evaluate(moisture) Result
    }
    class WeatherEvaluator {
        -rules: Hash
        +validate(...) Boolean
        +evaluate(rainfall_today_mm, forecast_rain_mm, temperature_c, humidity_pct) Result
    }
    class IrrigationDecisionEngine {
        -levels: Array
        -water_volume: Hash
        -schedule_rules: Hash
        +calculate_need(soil_score, weather_coefficient) NeedResult
        +calculate_volume(level, area_m2, soil_type) VolumeResult
        +schedule(level, current_hour_jst, temperature_c) ScheduleResult
    }
    class SessionManager {
        +generate_session_id() String
        +validate_session(session_id) Boolean
        +scope_query(relation, session_id) ActiveRecord::Relation
    }
    class HoneypotChecker {
        -field_name: String
        +check(form_data) Result
    }
    class DailyResetter {
        -reset_hour_jst: Integer
        +execute_reset() Boolean
        +due?(time_jst) Boolean
    }

    IrrigationDecisionEngine ..> IrrigationRules : load
    SoilMoistureEvaluator ..> IrrigationRules : load
    WeatherEvaluator ..> IrrigationRules : load
    DailyResetter ..> IrrigationRules : load
    HoneypotChecker ..> HoneypotConfig : load
    DailyResetter ..> SensorReading : update_all

    class ApiBaseController {
        <<Api::BaseController>>
        #current_session
        #ensure_session!()
        #scoped(relation)
        #check_honeypot!()
    }
    class ApiSessionsController {
        <<Api::SessionsController>>
        +show()
    }
    class ApiFieldSettingsController {
        <<Api::FieldSettingsController>>
        +show()
        +create()
    }
    class ApiSensorReadingsController {
        <<Api::SensorReadingsController>>
        +show()
        +create()
    }
    class ApiIrrigationsController {
        <<Api::IrrigationsController>>
        +create()
    }
    class ApiIrrigationLogsController {
        <<Api::IrrigationLogsController>>
        +index()
    }

    ApiBaseController <|-- ApiSessionsController
    ApiBaseController <|-- ApiFieldSettingsController
    ApiBaseController <|-- ApiSensorReadingsController
    ApiBaseController <|-- ApiIrrigationsController
    ApiBaseController <|-- ApiIrrigationLogsController

    ApiBaseController --> SessionManager
    ApiBaseController --> HoneypotChecker
    ApiSensorReadingsController --> SoilMoistureEvaluator
    ApiSensorReadingsController --> WeatherEvaluator
    ApiSensorReadingsController --> IrrigationDecisionEngine

    class Session {
        +id: String
        +last_active_at: DateTime
    }
    class FieldSetting {
        +area_m2: Float
        +soil_type: String
    }
    class SensorReading {
        +soil_moisture_pct: Float
        +rainfall_today_mm: Float
        +forecast_rain_mm: Float
        +temperature_c: Float
        +humidity_pct: Float
        +recorded_at: DateTime
    }
    class IrrigationLog {
        +decision: String
        +soil_moisture: Float
        +weather_coeff: Float
        +total_score: Float
        +recommended_l: Float
        +action_taken: String
        +executed_at: DateTime
    }

    Session "1" --> "*" FieldSetting
    Session "1" --> "*" SensorReading
    Session "1" --> "*" IrrigationLog
```

---

## 5. 状態遷移図

### 灌水判定の状態遷移（`schedule.action` は `IrrigationDecisionEngine#schedule` の戻り値）

```mermaid
stateDiagram-v2
    [*] --> NoData: データ未入力
    NoData --> Evaluating: POST /api/sensor

    Evaluating --> Immediate: total_score >= 0.7
    Evaluating --> Recommended: 0.4 <= total_score < 0.7
    Evaluating --> Watch: 0.2 <= total_score < 0.4
    Evaluating --> None: total_score < 0.2

    state Immediate {
        [*] --> DecideTiming
        DecideTiming --> ExecuteNow: 通常時間帯
        DecideTiming --> WaitUntilEvening: 10-16時 かつ 気温>30℃
        DecideTiming --> EmergencyConfirm: 22-5時（夜間）
    }

    Recommended --> NextMorning: action=next_morning（6-8時目安）
    Watch --> ReevaluateTomorrow: action=reevaluate_tomorrow
    None --> Skip: action=skip（記録ボタン無効）

    ExecuteNow --> Recorded: POST /api/irrigate
    WaitUntilEvening --> Recorded: 推奨時刻に記録
    NextMorning --> Recorded: 翌朝に記録
    EmergencyConfirm --> ConfirmModal: 記録ボタン押下
    ConfirmModal --> Recorded: 確認モーダルで実行を選択
    ConfirmModal --> Immediate: キャンセル

    Recorded --> [*]: irrigation_logs保存・/historyへ

    note right of Skip
        canRecord = decision.level != "none"
        Noneの場合は記録ボタンがdisabled
    end note

    note left of NoData
        JST 03:00（どの状態でも並行して発生）
        DailyResetter が全セッションの
        rainfall_today_mm を0にリセット
    end note
```

---

## 6. ユースケース図

```mermaid
flowchart TB
    User(("デモユーザー"))
    Scheduler(("システムスケジューラー"))

    subgraph SYS["auto-irrigation-demo システム"]
        UC01(["UC-01 ダッシュボードを閲覧する<br/>( / )"])
        UC02(["UC-02 センサーデータを入力する<br/>( /sensor )"])
        UC03(["UC-03 圃場設定を行う<br/>( /settings )"])
        UC04(["UC-04 灌水要否判定を確認する"])
        UC05(["UC-05 推奨水量を確認する"])
        UC06(["UC-06 推奨タイミングを確認する"])
        UC07(["UC-07 灌水実行を記録する"])
        UC07c(["UC-07c 夜間実行を確認する<br/>(ConfirmModal)"])
        UC08(["UC-08 灌水履歴を閲覧する<br/>( /history )"])
        UC09(["UC-09 Botチェックを通過する<br/>(ハニーポット)"])
        UC10(["UC-10 日次リセットを実行する<br/>(JST 03:00 自動)"])
        UC11(["UC-11 表示言語を切り替える<br/>(7言語, ar時はRTL)"])
    end

    User --> UC01
    User --> UC02
    User --> UC03
    User --> UC04
    User --> UC07
    User --> UC08
    User --> UC11

    UC02 -.include.-> UC09
    UC03 -.include.-> UC09
    UC07 -.include.-> UC09
    UC04 -.include.-> UC05
    UC04 -.include.-> UC06
    UC07 -.extend.-> UC07c

    Scheduler --> UC10
```
