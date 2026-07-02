"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useTranslations } from "next-intl";
import { apiClient } from "@/lib/api";
import type { FieldSettingResponse, SensorAssessmentResponse } from "@/lib/types";
import { ArcGauge } from "@/components/ArcGauge";
import { DecisionBadge } from "@/components/DecisionBadge";
import { ConfirmModal } from "@/components/ConfirmModal";

export default function DashboardPage() {
  const t = useTranslations("dashboard");
  const soilLabelsT = useTranslations("soilLabels");
  const weatherReasonsT = useTranslations("weatherReasons");
  const scheduleActionsT = useTranslations("scheduleActions");
  const soilTypesT = useTranslations("soilTypes");
  const modalT = useTranslations("modal.emergencyIrrigation");
  const router = useRouter();

  const [assessment, setAssessment] = useState<SensorAssessmentResponse | null>(null);
  const [fieldSetting, setFieldSetting] = useState<FieldSettingResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isRecording, setIsRecording] = useState(false);
  const [showEmergencyConfirm, setShowEmergencyConfirm] = useState(false);

  useEffect(() => {
    let cancelled = false;

    Promise.all([apiClient.getLatestAssessment(), apiClient.getFieldSetting()]).then(
      ([latestAssessment, latestFieldSetting]) => {
        if (!cancelled) {
          setAssessment(latestAssessment);
          setFieldSetting(latestFieldSetting);
          setIsLoading(false);
        }
      }
    );

    return () => {
      cancelled = true;
    };
  }, []);

  const recordIrrigation = useCallback(async () => {
    if (!assessment) return;

    setIsRecording(true);
    try {
      await apiClient.recordIrrigation({
        decision: assessment.decision.level,
        soil_moisture: assessment.sensor.soil_moisture_pct,
        weather_coeff: assessment.weather.coefficient,
        total_score: assessment.decision.total_score,
        recommended_l: assessment.volume?.volume_l ?? 0,
        action_taken: assessment.schedule.action,
      });
      router.push("/history");
    } finally {
      setIsRecording(false);
      setShowEmergencyConfirm(false);
    }
  }, [assessment, router]);

  function handleRecordClick() {
    if (assessment?.schedule.action === "emergency_confirm") {
      setShowEmergencyConfirm(true);
    } else {
      void recordIrrigation();
    }
  }

  if (isLoading) {
    return null;
  }

  if (!assessment) {
    return (
      <section className="card empty-state">
        <p>{t("emptyState.message")}</p>
        <button type="button" className="btn btn-primary" onClick={() => router.push("/sensor")}>
          {t("emptyState.cta")}
        </button>
      </section>
    );
  }

  const unitVolumeLPerM2 =
    fieldSetting && assessment.volume ? assessment.volume.volume_l / fieldSetting.area_m2 : null;
  const canRecord = assessment.decision.level !== "none";

  return (
    <>
      <section className="card">
        <h1 className="card-title">{t("title")}</h1>
        <ArcGauge value={assessment.sensor.soil_moisture_pct} label={t("soilMoisture")} />

        <div className="metrics-row">
          <div className="metric">
            <div className="metric-value">{assessment.soil.score.toFixed(2)}</div>
            <div className="metric-label">{t("soilScore")}</div>
          </div>
          <div className="metric">
            <div className="metric-value">{assessment.weather.coefficient.toFixed(2)}</div>
            <div className="metric-label">{t("weatherCoefficient")}</div>
          </div>
          <div className="metric">
            <div className="metric-value">{assessment.decision.total_score.toFixed(2)}</div>
            <div className="metric-label">{t("totalScore")}</div>
          </div>
        </div>

        <p>{soilLabelsT(assessment.soil.label)}</p>
        <p>{assessment.weather.reasons.map((reason) => weatherReasonsT(reason)).join(" / ")}</p>
        <DecisionBadge level={assessment.decision.level} />
      </section>

      <section className="card">
        <h2 className="card-title">{t("weatherCondition")}</h2>
        <div className="weather-grid">
          <div className="metric">
            <div className="metric-value">{assessment.sensor.temperature_c}</div>
            <div className="metric-label">{t("weatherGrid.temperature")}</div>
          </div>
          <div className="metric">
            <div className="metric-value">{assessment.sensor.humidity_pct}</div>
            <div className="metric-label">{t("weatherGrid.humidity")}</div>
          </div>
          <div className="metric">
            <div className="metric-value">{assessment.sensor.rainfall_today_mm}</div>
            <div className="metric-label">{t("weatherGrid.rainfallToday")}</div>
          </div>
          <div className="metric">
            <div className="metric-value">{assessment.sensor.forecast_rain_mm}</div>
            <div className="metric-label">{t("weatherGrid.forecastRain")}</div>
          </div>
        </div>
      </section>

      <section className="card">
        <h2 className="card-title">{t("recommendedAction.title")}</h2>
        <p>{scheduleActionsT(assessment.schedule.action)}</p>
        <div className="metrics-row">
          <div className="metric">
            <div className="metric-value">{assessment.volume ? assessment.volume.volume_l : "-"}</div>
            <div className="metric-label">{t("recommendedAction.volume")}</div>
          </div>
          <div className="metric">
            <div className="metric-value">{unitVolumeLPerM2 !== null ? unitVolumeLPerM2.toFixed(2) : "-"}</div>
            <div className="metric-label">{t("recommendedAction.unitVolume")}</div>
          </div>
          <div className="metric">
            <div className="metric-value">{fieldSetting ? fieldSetting.area_m2 : "-"}</div>
            <div className="metric-label">{t("recommendedAction.area")}</div>
          </div>
          <div className="metric">
            <div className="metric-value">{fieldSetting ? soilTypesT(fieldSetting.soil_type) : "-"}</div>
            <div className="metric-label">{t("recommendedAction.soilType")}</div>
          </div>
        </div>
        <p className="metric-label">
          {t("recommendedAction.lastUpdated")}: {new Date(assessment.recorded_at).toLocaleString()}
        </p>
      </section>

      <div className="modal-actions">
        <button type="button" className="btn" onClick={() => router.push("/sensor")}>
          {t("buttons.updateSensor")}
        </button>
        <button
          type="button"
          className="btn btn-primary"
          disabled={!canRecord || isRecording}
          onClick={handleRecordClick}
        >
          {t("buttons.recordIrrigation")}
        </button>
      </div>

      <ConfirmModal
        isOpen={showEmergencyConfirm}
        title={modalT("title")}
        body={modalT("body")}
        onConfirm={() => void recordIrrigation()}
        onCancel={() => setShowEmergencyConfirm(false)}
      />
    </>
  );
}
