import fs from "fs";
import path from "path";
import ts from "typescript";

// UI表示文言をコードに直書きしないためのコンプライアンステスト（coding-style.md）。
// src/ 配下の.ts/.tsxの文字列リテラル・JSXテキスト(コメントは除く)に
// 日本語が含まれていないか静的に検査する。翻訳リソースは messages/*.json に分離する。
//
// 除外: app/legal/ は会社情報・規約の法的文書であり、
//       日本語テキストのハードコードが正当な例外として認められる。
const JAPANESE_CHAR_PATTERN = /[ぁ-んァ-ヶ一-龠]/;
const SRC_DIR = path.join(__dirname, "..", "src");

// 除外ディレクトリ（相対パス、OS 非依存）
const EXCLUDE_DIRS = ["app/legal"];

function collectSourceFiles(dir: string): string[] {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      const relFromSrc = path.relative(SRC_DIR, fullPath).replace(/\\/g, "/");
      if (EXCLUDE_DIRS.some((ex) => relFromSrc === ex || relFromSrc.startsWith(ex + "/"))) {
        return [];
      }
      return collectSourceFiles(fullPath);
    }
    if (/\.(ts|tsx)$/.test(entry.name)) return [fullPath];
    return [];
  });
}

function findJapaneseLiterals(filePath: string): string[] {
  const source = fs.readFileSync(filePath, "utf8");
  const sourceFile = ts.createSourceFile(filePath, source, ts.ScriptTarget.Latest, true);
  const offenders: string[] = [];

  function visit(node: ts.Node) {
    const isTextNode =
      ts.isStringLiteralLike(node) || (ts.isJsxText(node) && node.text.trim().length > 0);

    if (isTextNode && JAPANESE_CHAR_PATTERN.test(node.text)) {
      offenders.push(node.text.trim());
    }

    ts.forEachChild(node, visit);
  }

  visit(sourceFile);
  return offenders;
}

describe("ハードコードされたUI文言の検出", () => {
  const files = collectSourceFiles(SRC_DIR).sort();

  files.forEach((file) => {
    const relativePath = path.relative(path.join(__dirname, ".."), file);

    it(`${relativePath} に日本語の文字列リテラル(UI文言)が直書きされていないこと`, () => {
      const offenders = findJapaneseLiterals(file);
      expect(offenders).toEqual([]);
    });
  });
});
