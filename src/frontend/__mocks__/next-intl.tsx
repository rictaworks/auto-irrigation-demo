import { createContext, useContext, type ReactNode } from "react";

// Jestテスト用の next-intl 簡易モック。next-intl自体はESM専用配布のため、
// 単体テストではメッセージ解決の挙動のみを再現する軽量実装で代替する。
interface IntlContextValue {
  locale: string;
  messages: Record<string, unknown>;
}

const IntlContext = createContext<IntlContextValue>({ locale: "ja", messages: {} });

interface ProviderProps {
  locale: string;
  messages: Record<string, unknown>;
  children: ReactNode;
}

export function NextIntlClientProvider({ locale, messages, children }: ProviderProps) {
  return <IntlContext.Provider value={{ locale, messages }}>{children}</IntlContext.Provider>;
}

function resolve(messages: Record<string, unknown>, path: string): unknown {
  return path.split(".").reduce<unknown>((acc, key) => {
    if (acc && typeof acc === "object") {
      return (acc as Record<string, unknown>)[key];
    }
    return undefined;
  }, messages);
}

export function useTranslations(namespace?: string) {
  const { messages } = useContext(IntlContext);
  return (key: string): string => {
    const fullPath = namespace ? `${namespace}.${key}` : key;
    const value = resolve(messages, fullPath);
    return typeof value === "string" ? value : fullPath;
  };
}

export function useLocale(): string {
  return useContext(IntlContext).locale;
}
