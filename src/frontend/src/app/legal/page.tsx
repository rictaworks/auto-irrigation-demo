import Link from "next/link";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "利用規約・免責事項・連絡先 | 自動灌水デモ",
};

const sectionStyle: React.CSSProperties = {
  marginBottom: "40px",
};

const headingStyle: React.CSSProperties = {
  fontSize: "16px",
  fontWeight: 700,
  color: "var(--color-text)",
  marginBottom: "14px",
  paddingBottom: "10px",
  borderBottom: "1px solid var(--color-border)",
};

const listStyle: React.CSSProperties = {
  paddingLeft: "20px",
  display: "flex",
  flexDirection: "column",
  gap: "10px",
  fontSize: "14px",
  color: "var(--color-text-light)",
  lineHeight: 1.7,
};

const dtStyle: React.CSSProperties = {
  width: "80px",
  flexShrink: 0,
  color: "var(--color-accent)",
  fontSize: "14px",
};

const ddStyle: React.CSSProperties = {
  fontSize: "14px",
  color: "var(--color-text-light)",
};

const linkStyle: React.CSSProperties = {
  color: "var(--color-dark)",
  textDecoration: "none",
};

export default function LegalPage() {
  return (
    <div style={{ paddingTop: "16px" }}>
      <div style={{ marginBottom: "24px" }}>
        <Link
          href="/"
          style={{ color: "var(--color-accent)", fontSize: "14px", textDecoration: "none", display: "inline-flex", alignItems: "center", gap: "4px" }}
        >
          ← 自動灌水デモに戻る
        </Link>
      </div>

      <h1 style={{ fontSize: "20px", fontWeight: 700, color: "var(--color-text)", marginBottom: "32px" }}>
        利用規約・免責事項・連絡先
      </h1>

      {/* 利用規約 */}
      <section style={sectionStyle}>
        <h2 style={headingStyle}>利用規約</h2>
        <ul style={listStyle}>
          <li>本サービスはデモンストレーション目的のみで提供されます。商用利用・再配布は禁止します。</li>
          <li>サービスの内容は予告なく変更・停止する場合があります。</li>
          <li>センサーデータおよび灌水記録はサーバー再起動時にリセットされる場合があります。</li>
          <li>本サービスの利用に際し、本規約に同意したものとみなします。</li>
        </ul>
      </section>

      {/* 免責事項 */}
      <section style={sectionStyle}>
        <h2 style={headingStyle}>免責事項</h2>
        <ul style={listStyle}>
          <li>表示される灌水判定・推奨値はデモ用のサンプルデータです。実際の農業判断の代替となるものではありません。</li>
          <li>本サービスの利用により生じた損害について、Ricta Works は一切の責任を負いません。</li>
          <li>サービスの可用性・正確性・継続性を保証しません。</li>
        </ul>
      </section>

      {/* 連絡先 */}
      <section style={sectionStyle}>
        <h2 style={headingStyle}>連絡先</h2>
        <dl style={{ display: "flex", flexDirection: "column", gap: "10px" }}>
          {[
            { label: "屋号", value: "Ricta Works" },
            { label: "住所", value: "〒190-0022 東京都立川市錦町1丁目4-20 TSCビル5階" },
            { label: "電話", value: "070-5148-0380" },
          ].map(({ label, value }) => (
            <div key={label} style={{ display: "flex", gap: "16px" }}>
              <dt style={dtStyle}>{label}</dt>
              <dd style={ddStyle}>{value}</dd>
            </div>
          ))}
          <div style={{ display: "flex", gap: "16px" }}>
            <dt style={dtStyle}>メール</dt>
            <dd style={ddStyle}>
              <a href="mailto:info@rictaworks.jp" style={linkStyle}>info@rictaworks.jp</a>
            </dd>
          </div>
          <div style={{ display: "flex", gap: "16px" }}>
            <dt style={dtStyle}>Web</dt>
            <dd style={ddStyle}>
              <a href="https://rictaworks.jp" target="_blank" rel="noopener noreferrer" style={linkStyle}>https://rictaworks.jp</a>
            </dd>
          </div>
          <div style={{ display: "flex", gap: "16px" }}>
            <dt style={dtStyle}>X</dt>
            <dd style={ddStyle}>
              <a href="https://x.com/rictaworks" target="_blank" rel="noopener noreferrer" style={linkStyle}>@rictaworks</a>
            </dd>
          </div>
          <div style={{ display: "flex", gap: "16px" }}>
            <dt style={dtStyle}>GitHub</dt>
            <dd style={ddStyle}>
              <a href="https://github.com/rictaworks" target="_blank" rel="noopener noreferrer" style={linkStyle}>github.com/rictaworks</a>
            </dd>
          </div>
        </dl>
      </section>
    </div>
  );
}
