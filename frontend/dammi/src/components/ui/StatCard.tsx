import type { ReactNode } from "react";
import { classNames } from "../../lib/helpers";
import { Card } from "./Card";

type Tone = "default" | "danger" | "success";

export function StatCard({
  label,
  value,
  helper,
  tone = "default"
}: {
  label: string;
  value: ReactNode;
  helper?: string;
  tone?: Tone;
}) {
  return (
    <Card className={classNames("stat-card", `stat-card--${tone}`)}>
      <span className="stat-card__label">{label}</span>
      <strong className="stat-card__value">{value}</strong>
      {helper ? <span className="stat-card__helper">{helper}</span> : null}
    </Card>
  );
}