# auto-irrigation-demo

土壌・天気データ連動の自動灌水システム（デモ版）。詳細設計は [auto-irrigation-demo-spec.md](./auto-irrigation-demo-spec.md) を参照。

> 現時点では設計フェーズであり、Next.js/Railsの実装は未着手。以下のページ一覧・API一覧は設計書に基づく実装予定の内容。実装後は本README（および `SPEC/API.md`）を実際のルーティングに合わせて更新すること。

## 自動ログイン

このデモは認証を持たない。ページアクセス時にCookieのセッション（UUID v4）が無ければサーバー側で自動発行し、以降そのセッションIDをオーナーキーとして全データを紐付ける（`GET /api/session`）。ID/パスワード等の入力は不要（外部認証API禁止のため、Google OAuth等は使用しない）。

## ページ一覧

| ページ名 | URL |
|---|---|
| ダッシュボード | [`/`](/) |
| センサー入力フォーム | [`/sensor`](/sensor) |
| 灌水設定フォーム | [`/settings`](/settings) |
| 灌水履歴 | [`/history`](/history) |

## API一覧

詳細（リクエスト/レスポンスの仕様）は [`SPEC/API.md`](./SPEC/API.md) を参照。

| タイトル | エンドポイントURL |
|---|---|
| セッション確認・自動発行 | [`GET /api/session`](./SPEC/API.md) |
| センサーデータ送信・灌水判定 | [`POST /api/sensor`](./SPEC/API.md) |
| 灌水実行記録 | [`POST /api/irrigate`](./SPEC/API.md) |
| 圃場設定登録 | [`POST /api/field_settings`](./SPEC/API.md) |
| 灌水履歴取得 | [`GET /api/irrigation_logs`](./SPEC/API.md) |

## 開発ルール

開発フロー・コーディング規約・ディレクトリ運用等は [`CLAUDE.md`](./CLAUDE.md) および [`.claude/rules/`](./.claude/rules/) を参照。
