import { getRequestConfig } from "next-intl/server";
import { cookies } from "next/headers";
import { defaultLocale, isSupportedLocale, localeCookieName } from "./config";

export default getRequestConfig(async () => {
  const cookieStore = await cookies();
  const cookieLocale = cookieStore.get(localeCookieName)?.value;
  const locale = isSupportedLocale(cookieLocale) ? cookieLocale : defaultLocale;

  return {
    locale,
    messages: (await import(`../../messages/${locale}.json`)).default,
  };
});
