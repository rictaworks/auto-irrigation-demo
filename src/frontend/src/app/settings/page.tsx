"use client";

import { useEffect, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { useTranslations } from "next-intl";
import { apiClient, ApiError } from "@/lib/api";
import { HONEYPOT_FIELD_NAME } from "@/lib/honeypot";
import type { SoilType } from "@/lib/types";

const SOIL_TYPES: SoilType[] = ["sandy_loam", "loam", "clay"];

export default function SettingsPage() {
  const t = useTranslations("settingsForm");
  const soilTypeT = useTranslations("soilTypes");
  const errorsT = useTranslations("errors");
  const router = useRouter();

  const [areaM2, setAreaM2] = useState<string>("");
  const [soilType, setSoilType] = useState<SoilType>("loam");
  const [honeypot, setHoneypot] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    apiClient.getFieldSetting().then((setting) => {
      if (!cancelled && setting) {
        setAreaM2(String(setting.area_m2));
        setSoilType(setting.soil_type);
      }
    });

    return () => {
      cancelled = true;
    };
  }, []);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setIsSubmitting(true);
    setErrorMessage(null);
    setMessage(null);

    try {
      await apiClient.createFieldSetting(
        { area_m2: Number(areaM2), soil_type: soilType },
        honeypot
      );
      setMessage(t("success"));
    } catch (error) {
      setErrorMessage(error instanceof ApiError ? errorsT("validation") : errorsT("network"));
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <section className="card">
      <h1 className="card-title">{t("title")}</h1>
      <form onSubmit={handleSubmit}>
        <div className="form-field">
          <label htmlFor="area_m2">{t("areaM2")}</label>
          <input
            id="area_m2"
            type="number"
            min="0"
            step="0.1"
            required
            value={areaM2}
            onChange={(event) => setAreaM2(event.target.value)}
          />
        </div>

        <div className="form-field">
          <label htmlFor="soil_type">{t("soilType")}</label>
          <select
            id="soil_type"
            value={soilType}
            onChange={(event) => setSoilType(event.target.value as SoilType)}
          >
            {SOIL_TYPES.map((type) => (
              <option key={type} value={type}>
                {soilTypeT(type)}
              </option>
            ))}
          </select>
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

        {message && <p role="status">{message}</p>}
        {errorMessage && <p role="alert">{errorMessage}</p>}

        <div className="modal-actions">
          <button type="button" className="btn" onClick={() => router.push("/")}>
            {t("cancel")}
          </button>
          <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
            {t("save")}
          </button>
        </div>
      </form>
    </section>
  );
}
