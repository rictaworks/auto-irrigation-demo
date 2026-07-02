export const locales = ["ja", "en", "fr", "zh", "ru", "es", "ar"] as const;

export type Locale = (typeof locales)[number];

export const defaultLocale: Locale = "ja";

export const localeCookieName = "locale";

export const localeDirections: Record<Locale, "ltr" | "rtl"> = {
  ja: "ltr",
  en: "ltr",
  fr: "ltr",
  zh: "ltr",
  ru: "ltr",
  es: "ltr",
  ar: "rtl",
};

export function isSupportedLocale(value: string | undefined | null): value is Locale {
  if (!value) return false;
  return (locales as readonly string[]).includes(value);
}
