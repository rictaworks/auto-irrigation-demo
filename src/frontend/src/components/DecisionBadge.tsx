import { useTranslations } from "next-intl";
import type { DecisionLevel } from "@/lib/types";

export function DecisionBadge({ level }: { level: DecisionLevel }) {
  const t = useTranslations("decisionLevels");

  return <span className={`decision-badge decision-badge--${level}`}>{t(level)}</span>;
}
