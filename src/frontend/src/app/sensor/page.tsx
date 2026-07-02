"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { useTranslations } from "next-intl";
import { apiClient, ApiError } from "@/lib/api";
import { HONEYPOT_FIELD_NAME } from "@/lib/honeypot";

interface FormState {
  soil_moisture_pct: string;
  rainfall_today_mm: string;
  forecast_rain_mm: string;
  temperature_c: string;
  humidity_pct: string;
}

const INITIAL_FORM: FormState = {
  soil_moisture_pct: "",
  rainfall_today_mm: "",
  forecast_rain_mm: "",
  temperature_c: "",
  humidity_pct: "",
};

export default function SensorPage() {
  const t = useTranslations("sensorForm");
  const errorsT = useTranslations("errors");
  const router = useRouter();

  const [form, setForm] = useState<FormState>(INITIAL_FORM);
  const [honeypot, setHoneypot] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  function updateField(field: keyof FormState, value: string) {
    setForm((prev) => ({ ...prev, [field]: value }));
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setIsSubmitting(true);
    setErrorMessage(null);

    try {
      await apiClient.submitSensorReading(
        {
          soil_moisture_pct: Number(form.soil_moisture_pct),
          rainfall_today_mm: Number(form.rainfall_today_mm),
          forecast_rain_mm: Number(form.forecast_rain_mm),
          temperature_c: Number(form.temperature_c),
          humidity_pct: Number(form.humidity_pct),
        },
        honeypot
      );
      router.push("/");
    } catch (error) {
      setErrorMessage(error instanceof ApiError ? errorsT("validation") : errorsT("network"));
      setIsSubmitting(false);
    }
  }

  return (
    <section className="card">
      <h1 className="card-title">{t("title")}</h1>
      <form onSubmit={handleSubmit}>
        <div className="form-field">
          <label htmlFor="soil_moisture_pct">{t("soilMoisturePct")}</label>
          <input
            id="soil_moisture_pct"
            type="number"
            min="0"
            max="100"
            step="0.1"
            required
            value={form.soil_moisture_pct}
            onChange={(event) => updateField("soil_moisture_pct", event.target.value)}
          />
        </div>

        <div className="form-field">
          <label htmlFor="rainfall_today_mm">{t("rainfallTodayMm")}</label>
          <input
            id="rainfall_today_mm"
            type="number"
            min="0"
            step="0.1"
            required
            value={form.rainfall_today_mm}
            onChange={(event) => updateField("rainfall_today_mm", event.target.value)}
          />
        </div>

        <div className="form-field">
          <label htmlFor="forecast_rain_mm">{t("forecastRainMm")}</label>
          <input
            id="forecast_rain_mm"
            type="number"
            min="0"
            step="0.1"
            required
            value={form.forecast_rain_mm}
            onChange={(event) => updateField("forecast_rain_mm", event.target.value)}
          />
        </div>

        <div className="form-field">
          <label htmlFor="temperature_c">{t("temperatureC")}</label>
          <input
            id="temperature_c"
            type="number"
            step="0.1"
            required
            value={form.temperature_c}
            onChange={(event) => updateField("temperature_c", event.target.value)}
          />
        </div>

        <div className="form-field">
          <label htmlFor="humidity_pct">{t("humidityPct")}</label>
          <input
            id="humidity_pct"
            type="number"
            min="0"
            max="100"
            step="0.1"
            required
            value={form.humidity_pct}
            onChange={(event) => updateField("humidity_pct", event.target.value)}
          />
        </div>

        <input
          type="text"
          name={HONEYPOT_FIELD_NAME}
          className="honeypot-field"
          tabIndex={-1}
          autoComplete="off"
          aria-hidden="true"
          value={honeypot}
          onChange={(event) => setHoneypot(event.target.value)}
        />

        {errorMessage && <p role="alert">{errorMessage}</p>}

        <div className="modal-actions">
          <button type="button" className="btn" onClick={() => router.push("/")}>
            {t("cancel")}
          </button>
          <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
            {t("submit")}
          </button>
        </div>
      </form>
    </section>
  );
}
