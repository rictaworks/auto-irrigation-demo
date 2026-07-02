import { test, expect } from "@playwright/test";

// メインフロー: ダッシュボード(空状態) → センサー入力 → 判定結果表示 →
// 灌水記録 → 履歴反映 (auto-irrigation-demo-spec.md 4.1 シーケンス図に対応)
test("センサー入力から灌水記録・履歴反映までの一連の操作ができる", async ({ page }) => {
  await page.goto("/settings");
  await page.getByLabel("圃場面積 (m²)").fill("100");
  await page.getByLabel("土壌種別").selectOption("sandy_loam");
  await page.getByRole("button", { name: "設定を保存" }).click();
  await expect(page.getByText("設定を保存しました")).toBeVisible();

  await page.goto("/sensor");
  await page.getByLabel("土壌水分量 (%)").fill("15");
  await page.getByLabel("当日降雨量 (mm)").fill("0");
  await page.getByLabel("24時間予報降雨量 (mm)").fill("0");
  await page.getByLabel("気温 (℃)").fill("20");
  await page.getByLabel("湿度 (%)").fill("50");
  await page.getByRole("button", { name: "判定を実行する" }).click();

  await expect(page).toHaveURL("/");
  await expect(page.getByText("今すぐ灌水")).toBeVisible();

  const recordButton = page.getByRole("button", { name: "灌水を記録する" });
  await recordButton.click();

  const confirmButton = page.getByRole("button", { name: "実行する" });
  if (await confirmButton.isVisible().catch(() => false)) {
    await confirmButton.click();
  }

  await expect(page).toHaveURL("/history");
  await expect(page.getByRole("table")).toBeVisible();
  await expect(page.getByText("今すぐ灌水")).toBeVisible();
});
