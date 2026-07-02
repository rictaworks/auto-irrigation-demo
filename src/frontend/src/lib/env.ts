// 環境（development/production）の判定・分岐を一元化する（architecture.md）。
export const isDevelopment = process.env.NODE_ENV === "development";
export const isProduction = process.env.NODE_ENV === "production";

export function getApiBaseUrl(): string {
  const url = process.env.NEXT_PUBLIC_API_BASE_URL;
  if (!url) {
    throw new Error("NEXT_PUBLIC_API_BASE_URL is not set");
  }
  return url;
}
