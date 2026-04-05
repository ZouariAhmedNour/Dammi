import type { ReactNode } from "react";
import { classNames } from "../../lib/helpers";

type Variant = "default" | "success" | "warning" | "danger" | "info";

export function Badge({
  children,
  variant = "default"
}: {
  children: ReactNode;
  variant?: Variant;
}) {
  return <span className={classNames("badge", `badge--${variant}`)}>{children}</span>;
}