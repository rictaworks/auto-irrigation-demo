# SPEC/

仕様書・リバースエンジニアリング成果物（ER図・DFD・シーケンス図・クラス図・状態遷移図・ユースケース図）を管理するディレクトリ。図解は Mermaid 記法で記述する。

- 初期設計書は `/auto-irrigation-demo-spec.md`（リポジトリ直下）にある。以降の更新・追加の図表はこの `SPEC/` 配下に追加する。
- Mermaid記法の図はGitHub上でそのまま描画される。ローカルでのプレビュー・画像出力が必要な場合は、Next.jsプロジェクト作成後に `@mermaid-js/mermaid-cli` を devDependency として追加する（現時点ではNode.jsプロジェクトが未作成のためグローバルインストールは行っていない）。
