require "rails_helper"
require "ripper"

# UI表示文言・設定値をコードに直書きしないためのコンプライアンステスト（coding-style.md）。
# app/ 配下の.rbファイルの文字列リテラル(コメントは除く)に日本語が含まれていないか静的に検査する。
# 判定結果はコードではなくenumで返す設計のため、バックエンドのUI文言は本来存在しない想定。
RSpec.describe "ハードコードされたUI文言の検出" do
  JAPANESE_CHAR_PATTERN = /[ぁ-んァ-ヶ一-龠]/

  def string_literals_with_japanese(file)
    tokens = Ripper.lex(File.read(file))

    tokens
      .select { |(_pos, type, _tok, _state)| type == :on_tstring_content }
      .map { |(_pos, _type, tok, _state)| tok }
      .select { |tok| tok.match?(JAPANESE_CHAR_PATTERN) }
  end

  Dir.glob(Rails.root.join("app/**/*.rb")).sort.each do |file|
    relative_path = Pathname.new(file).relative_path_from(Rails.root).to_s

    it "#{relative_path} に日本語の文字列リテラル(UI文言)が直書きされていないこと" do
      offenders = string_literals_with_japanese(file)
      expect(offenders).to be_empty,
        "日本語の文字列リテラルが見つかりました。設定ファイル(config/*.yml)または" \
        "フロントエンドの翻訳リソースに分離してください: #{offenders.join(', ')}"
    end
  end
end
