import type { Metadata } from "next";
import Script from "next/script";
import { NextIntlClientProvider } from "next-intl";
import { getLocale, getTranslations } from "next-intl/server";
import { config as faConfig } from "@fortawesome/fontawesome-svg-core";
import "@fortawesome/fontawesome-svg-core/styles.css";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faCommentDots } from "@fortawesome/free-solid-svg-icons";
import { defaultLocale, isSupportedLocale, localeDirections } from "@/i18n/config";
import { SessionProvider } from "@/context/SessionContext";
import { Nav } from "@/components/Nav";
import "./globals.css";

faConfig.autoAddCss = false;

export async function generateMetadata(): Promise<Metadata> {
  const t = await getTranslations("scaffold");
  return {
    title: t("pageTitle"),
    description: "Auto-Irrigation Demo",
  };
}

export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const locale = await getLocale();
  const dir = isSupportedLocale(locale) ? localeDirections[locale] : localeDirections[defaultLocale];
  const t = await getTranslations("scaffold");

  return (
    <html lang={locale} dir={dir}>
      <body>
        {/* アンバーバナー */}
        <div style={{
          position: "fixed",
          top: 0,
          left: 0,
          right: 0,
          zIndex: 200,
          background: "#d97706",
          color: "#fff",
          fontSize: "12px",
          fontWeight: 500,
          textAlign: "center",
          padding: "6px 16px",
          lineHeight: 1.5,
        }}>
          {t("demoBanner")}
        </div>

        {/* バナー高さ分スペーサー */}
        <div style={{ height: "30px" }} />

        <NextIntlClientProvider>
          <SessionProvider>
            <Nav />
            <main className="app-shell">{children}</main>
          </SessionProvider>
        </NextIntlClientProvider>

        {/* フッター */}
        <footer style={{
          borderTop: "1px solid var(--color-border)",
          padding: "16px 24px",
          textAlign: "center",
          fontSize: "12px",
          color: "var(--color-accent)",
        }}>
          <a
            href="/legal"
            style={{ color: "var(--color-accent)", textDecoration: "none" }}
          >
            {t("footerLegal")}
          </a>
          <span style={{ margin: "0 8px" }}>|</span>
          <span>{t("footerCopyright")}</span>
        </footer>

        {/* GA4 */}
        <Script src="https://www.googletagmanager.com/gtag/js?id=G-C04W1XKS16" strategy="afterInteractive" />
        <Script id="ga4-init" strategy="afterInteractive">{`
          window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('js', new Date());
          gtag('config', 'G-C04W1XKS16');
        `}</Script>

        {/* 右下固定ご相談ボタン */}
        <a
          href="https://rictaworks.jp/"
          target="_blank"
          rel="noopener noreferrer"
          style={{
            position: "fixed",
            bottom: "1.5rem",
            right: "1.5rem",
            zIndex: 300,
            background: "var(--color-dark)",
            color: "#fff",
            textDecoration: "none",
            borderRadius: "9999px",
            padding: "10px 18px",
            fontSize: "13px",
            fontWeight: 600,
            display: "flex",
            alignItems: "center",
            gap: "7px",
            boxShadow: "0 4px 14px rgba(0,0,0,0.25)",
            whiteSpace: "nowrap",
          }}
        >
          <FontAwesomeIcon icon={faCommentDots} />
          {t("consultCta")}
        </a>
      </body>
    </html>
  );
}
