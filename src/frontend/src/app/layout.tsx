import type { Metadata } from "next";
import { NextIntlClientProvider } from "next-intl";
import { getLocale, getTranslations } from "next-intl/server";
import { config as faConfig } from "@fortawesome/fontawesome-svg-core";
import "@fortawesome/fontawesome-svg-core/styles.css";
import { defaultLocale, isSupportedLocale, localeDirections } from "@/i18n/config";
import { SessionProvider } from "@/context/SessionContext";
import { Nav } from "@/components/Nav";
import "./globals.css";

faConfig.autoAddCss = false;

export async function generateMetadata(): Promise<Metadata> {
  const t = await getTranslations("app");
  return {
    title: t("title"),
    description: t("subtitle"),
  };
}

export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const locale = await getLocale();
  const dir = isSupportedLocale(locale) ? localeDirections[locale] : localeDirections[defaultLocale];

  return (
    <html lang={locale} dir={dir}>
      <body>
        <NextIntlClientProvider>
          <SessionProvider>
            <Nav />
            <main className="app-shell">{children}</main>
          </SessionProvider>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
