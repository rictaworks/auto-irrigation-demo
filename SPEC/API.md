# API一覧

詳細な処理内容は [auto-irrigation-demo-spec.md](../auto-irrigation-demo-spec.md) の「4. シーケンス図」「5. クラス図」を参照。

実装済み（`src/backend`、Rails API mode）。

| タイトル | エンドポイントURL | 概要 | 状態 |
|---|---|---|---|
| セッション確認・自動発行 | `GET /api/session` | Cookie(署名付きUUID v4)のセッションが無ければ新規発行する（認証不要の自動ログイン相当） | 実装済み |
| 圃場設定取得 | `GET /api/field_settings` | 当セッションの最新の圃場設定を取得する（未設定時は`null`） | 実装済み |
| 圃場設定登録 | `POST /api/field_settings` | 面積・土壌種別を登録する（S-03 灌水設定フォームから使用） | 実装済み |
| 直近センサー評価取得 | `GET /api/sensor` | 直近のセンサー入力を現在の圃場設定・時刻で再評価して返す（未入力時は`null`。ダッシュボードのリロード時表示に使用） | 実装済み |
| センサーデータ送信・灌水判定 | `POST /api/sensor` | 土壌水分・天気データを受信し、Botチェック→土壌水分評価→天気条件評価→灌水要否判定→推奨水量算出→スケジューリングを行い結果を返す | 実装済み |
| 灌水実行記録 | `POST /api/irrigate` | ユーザーが灌水を実行したことを `irrigation_logs` に記録する | 実装済み |
| 灌水履歴取得 | `GET /api/irrigation_logs` | 当セッションの灌水操作ログ一覧を取得する（S-04 灌水履歴から使用） | 実装済み |

判定結果・decision/soil_type等は言語非依存のコード（enum文字列）で返却する。UI表示文言はフロントエンド(`src/frontend/messages/*.json`)側で多言語化する。

POST系エンドポイントは全てハニーポットフィールド(`contact_url`)をトップレベルに含めることができ、値が入っている場合はBotとみなし200 OKを返しつつ処理を中断する。

## スケジュールジョブ（HTTP APIではない）

| タイトル | 実行契機 | 概要 |
|---|---|---|
| 日次リセット | JST 03:00（Rails Cron / whenever gem） | 当日降雨量カウンターを全セッション分リセットする |
