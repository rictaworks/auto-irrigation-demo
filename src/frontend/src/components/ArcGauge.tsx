interface ArcGaugeProps {
  value: number;
  label: string;
}

const RADIUS = 52;
const CIRCUMFERENCE = 2 * Math.PI * RADIUS;

export function ArcGauge({ value, label }: ArcGaugeProps) {
  const clamped = Math.min(100, Math.max(0, value));
  const offset = CIRCUMFERENCE * (1 - clamped / 100);

  return (
    <div className="arc-gauge" role="img" aria-label={`${label}: ${clamped}%`}>
      <svg viewBox="0 0 120 120" width="120" height="120">
        <circle cx="60" cy="60" r={RADIUS} fill="none" stroke="var(--color-border)" strokeWidth="10" />
        <circle
          cx="60"
          cy="60"
          r={RADIUS}
          fill="none"
          stroke="var(--color-accent)"
          strokeWidth="10"
          strokeDasharray={CIRCUMFERENCE}
          strokeDashoffset={offset}
          strokeLinecap="round"
          transform="rotate(-90 60 60)"
        />
        <text x="60" y="66" textAnchor="middle" fontSize="22" fill="var(--color-text)">
          {Math.round(clamped)}%
        </text>
      </svg>
      <div className="arc-gauge-label">{label}</div>
    </div>
  );
}
