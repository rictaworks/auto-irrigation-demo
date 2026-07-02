"use client";

import { useLocale, useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { useTransition, type ChangeEvent } from "react";
import { locales } from "@/i18n/config";
import { setLocale } from "@/i18n/setLocale";

export function LocaleSwitcher() {
  const t = useTranslations("localeSwitcher");
  const namesT = useTranslations("localeNames");
  const currentLocale = useLocale();
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  function handleChange(event: ChangeEvent<HTMLSelectElement>) {
    const nextLocale = event.target.value;
    startTransition(async () => {
      await setLocale(nextLocale);
      router.refresh();
    });
  }

  return (
    <label>
      <span className="sr-only">{t("label")}</span>
      <select value={currentLocale} onChange={handleChange} disabled={isPending}>
        {locales.map((code) => (
          <option key={code} value={code}>
            {namesT(code)}
          </option>
        ))}
      </select>
    </label>
  );
}
