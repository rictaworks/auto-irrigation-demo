export type DecisionLevel = "immediate" | "recommended" | "watch" | "none";
export type SoilType = "sandy_loam" | "loam" | "clay";

export interface FieldSettingResponse {
  id: number;
  area_m2: number;
  soil_type: SoilType;
}

export interface SensorReadingInput {
  soil_moisture_pct: number;
  rainfall_today_mm: number;
  forecast_rain_mm: number;
  temperature_c: number;
  humidity_pct: number;
}

export interface SensorAssessmentResponse {
  sensor_reading_id: number;
  recorded_at: string;
  soil: { label: string; score: number };
  weather: { coefficient: number; reasons: string[] };
  decision: { level: DecisionLevel; total_score: number };
  volume: { volume_l: number } | null;
  schedule: { action: string; recommended_hour: number | null };
  sensor: SensorReadingInput;
}

export interface IrrigationLogInput {
  decision: DecisionLevel;
  soil_moisture: number;
  weather_coeff: number;
  total_score: number;
  recommended_l: number;
  action_taken: string;
}

export interface IrrigationLogResponse {
  id: number;
  decision: DecisionLevel;
  soil_moisture?: number;
  total_score?: number;
  recommended_l: number;
  action_taken: string;
  executed_at: string;
}
