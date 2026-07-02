"use server";

import { cookies } from "next/headers";
import { isSupportedLocale, localeCookieName } from "./config";

export async function setLocale(locale: string): Promise<void> {
  if (!isSupportedLocale(locale)) {
    throw new Error(`unsupported locale: ${locale}`);
  }

  const cookieStore = await cookies();
  cookieStore.set(localeCookieName, locale, {
    path: "/",
    sameSite: "lax",
    maxAge: 60 * 60 * 24 * 365,
  });
}
