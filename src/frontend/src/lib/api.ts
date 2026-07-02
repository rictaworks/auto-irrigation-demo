import { getApiBaseUrl } from "./env";
import { HONEYPOT_FIELD_NAME } from "./honeypot";
import type {
  FieldSettingResponse,
  IrrigationLogInput,
  IrrigationLogResponse,
  SensorAssessmentResponse,
  SensorReadingInput,
} from "./types";

export class ApiError extends Error {
  readonly status: number;
  readonly payload: unknown;

  constructor(status: number, payload: unknown) {
    super(`API request failed with status ${status}`);
    this.name = "ApiError";
    this.status = status;
    this.payload = payload;
  }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  let response: Response;
  try {
    response = await fetch(`${getApiBaseUrl()}${path}`, {
      ...options,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        ...options.headers,
      },
    });
  } catch (cause) {
    throw new ApiError(0, { cause });
  }

  if (!response.ok) {
    const payload = await response.json().catch(() => null);
    throw new ApiError(response.status, payload);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}

function withHoneypot(body: Record<string, unknown>, honeypotValue: string): string {
  return JSON.stringify({ ...body, [HONEYPOT_FIELD_NAME]: honeypotValue });
}

export const apiClient = {
  getSession(): Promise<{ session_id: string }> {
    return request("/api/session");
  },

  getFieldSetting(): Promise<FieldSettingResponse | null> {
    return request("/api/field_settings");
  },

  createFieldSetting(
    data: { area_m2: number; soil_type: string },
    honeypotValue = ""
  ): Promise<FieldSettingResponse> {
    return request("/api/field_settings", {
      method: "POST",
      body: withHoneypot({ field_setting: data }, honeypotValue),
    });
  },

  getLatestAssessment(): Promise<SensorAssessmentResponse | null> {
    return request("/api/sensor");
  },

  submitSensorReading(
    data: SensorReadingInput,
    honeypotValue = ""
  ): Promise<SensorAssessmentResponse> {
    return request("/api/sensor", {
      method: "POST",
      body: withHoneypot({ sensor_reading: data }, honeypotValue),
    });
  },

  recordIrrigation(
    data: IrrigationLogInput,
    honeypotValue = ""
  ): Promise<IrrigationLogResponse> {
    return request("/api/irrigate", {
      method: "POST",
      body: withHoneypot({ irrigation_log: data }, honeypotValue),
    });
  },

  getIrrigationLogs(): Promise<IrrigationLogResponse[]> {
    return request("/api/irrigation_logs");
  },
};
