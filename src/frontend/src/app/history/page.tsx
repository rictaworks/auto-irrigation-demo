"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { apiClient } from "@/lib/api";
import type { IrrigationLogResponse } from "@/lib/types";
import { DecisionBadge } from "@/components/DecisionBadge";

export default function HistoryPage() {
  const t = useTranslations("history");
  const scheduleActionsT = useTranslations("scheduleActions");

  const [logs, setLogs] = useState<IrrigationLogResponse[] | null>(null);

  useEffect(() => {
    let cancelled = false;

    apiClient.getIrrigationLogs().then((result) => {
      if (!cancelled) setLogs(result);
    });

    return () => {
      cancelled = true;
    };
  }, []);

  return (
    <section className="card">
      <h1 className="card-title">{t("title")}</h1>

      {logs === null && null}

      {logs !== null && logs.length === 0 && <p className="empty-state">{t("empty")}</p>}

      {logs !== null && logs.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>{t("columns.executedAt")}</th>
              <th>{t("columns.decision")}</th>
              <th>{t("columns.soilMoisture")}</th>
              <th>{t("columns.score")}</th>
              <th>{t("columns.volume")}</th>
              <th>{t("columns.action")}</th>
            </tr>
          </thead>
          <tbody>
            {logs.map((log) => (
              <tr key={log.id}>
                <td>{new Date(log.executed_at).toLocaleString()}</td>
                <td>
                  <DecisionBadge level={log.decision} />
                </td>
                <td>{log.soil_moisture ?? "-"}</td>
                <td>{log.total_score ?? "-"}</td>
                <td>{log.recommended_l}</td>
                <td>{scheduleActionsT(log.action_taken)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </section>
  );
}
