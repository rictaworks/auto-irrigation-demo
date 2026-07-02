import { apiClient, ApiError } from "@/lib/api";

const originalFetch = global.fetch;

describe("apiClient", () => {
  beforeEach(() => {
    process.env.NEXT_PUBLIC_API_BASE_URL = "http://localhost:3001";
  });

  afterEach(() => {
    global.fetch = originalFetch;
    jest.restoreAllMocks();
  });

  it("getSessionはCookie付きでGET /api/sessionを呼ぶ", async () => {
    const mockFetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({ session_id: "abc" }),
    });
    global.fetch = mockFetch as unknown as typeof fetch;

    const result = await apiClient.getSession();

    expect(result).toEqual({ session_id: "abc" });
    expect(mockFetch).toHaveBeenCalledWith(
      "http://localhost:3001/api/session",
      expect.objectContaining({ credentials: "include" })
    );
  });

  it("getFieldSettingは未設定時にnullを返す", async () => {
    const mockFetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => null,
    });
    global.fetch = mockFetch as unknown as typeof fetch;

    const result = await apiClient.getFieldSetting();
    expect(result).toBeNull();
  });

  it("submitSensorReadingはハニーポットフィールドを含めて送信する", async () => {
    const mockFetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 201,
      json: async () => ({
        sensor_reading_id: 1,
        soil: { label: "critical", score: 1.0 },
        weather: { coefficient: 1.0, reasons: ["standard"] },
        decision: { level: "immediate", total_score: 1.0 },
        volume: { volume_l: 500 },
        schedule: { action: "execute_now", recommended_hour: 10 },
      }),
    });
    global.fetch = mockFetch as unknown as typeof fetch;

    await apiClient.submitSensorReading({
      soil_moisture_pct: 15,
      rainfall_today_mm: 0,
      forecast_rain_mm: 0,
      temperature_c: 20,
      humidity_pct: 50,
    });

    const [, options] = mockFetch.mock.calls[0];
    const body = JSON.parse(options.body as string);
    expect(body.sensor_reading.soil_moisture_pct).toBe(15);
    expect(body.contact_url).toBe("");
  });

  it("エラーレスポンスはApiErrorを送出する", async () => {
    const mockFetch = jest.fn().mockResolvedValue({
      ok: false,
      status: 422,
      json: async () => ({ error: "unprocessable" }),
    });
    global.fetch = mockFetch as unknown as typeof fetch;

    await expect(apiClient.getIrrigationLogs()).rejects.toBeInstanceOf(ApiError);
  });
});
