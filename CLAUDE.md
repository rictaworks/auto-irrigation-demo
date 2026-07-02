# Claude Safety Rules

## 削除系コマンドの禁止（重要）

以下のルールはこのワークスペース内のすべての会話で絶対に守られる：

- Claude はファイルまたはディレクトリを削除するコマンドを一切生成してはならない。
  例：rm, rm -rf, rm *, rmdir, unlink, cache --delete,
      lftp mirror --delete, rsync --delete, git clean -df, find -delete 等。

- 削除が必要な場合でも、Claude は削除コマンドを提案せず、
  「手動で削除してください」といった説明に留めること。

- 削除の推奨・削除操作の自動判断も禁止。

- ssh / lftp / デプロイ系スクリプトを生成する場合でも、
  削除コマンドの生成は禁止。

これらはすべての会話・コード生成に適用される。

## シークレット管理（重要）

- `config/master.key` など機密ファイルを `git add` するコードを生成してはならない
- デプロイスクリプト・セットアップ手順でも同様
- シークレットは必ず環境変数（RAILS_MASTER_KEY 等）で渡すこと
- `.gitignore` への追加を確認する手順を必ずコードに含めること
- 初回コミット前に `git status` でステージング確認を促すこと

## 関連ルール

関心事ごとに `.claude/rules/` 以下へ分割している。各ファイルは自動的に読み込まれる。

- @.claude/rules/workflow.md — 開発フロー（TDD・JST/UTF-8・フロント確認手段・commit前security review・参照ドキュメント）
- @.claude/rules/git-branching.md — ブランチ運用・PR規約
- @.claude/rules/coding-style.md — コーディング規約（グローバル変数禁止・文字列外部化・UI規約）
- @.claude/rules/architecture.md — 技術スタック・デプロイ・認証方針
- @.claude/rules/i18n.md — 多言語対応方針
- @.claude/rules/project-structure.md — ディレクトリ運用（TASKS/DEBUG/CLIENT/WORK/ENV/SPEC/DELETE）

参照ドキュメント: @.claude/CC.md（コンプライアンス）, @.claude/QC10.md（品質）, @.claude/TM.md（テスト手法）, @.claude/OWASP10.md（セキュリティ）, @.claude/CRAP.md（デザイン4原則）, @.claude/development-principles.md（開発原則）