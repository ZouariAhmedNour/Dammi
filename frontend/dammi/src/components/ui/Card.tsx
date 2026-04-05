import type { HTMLAttributes, ReactNode } from "react";
import { classNames } from "../../lib/helpers";

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  title?: string;
  subtitle?: string;
  actions?: ReactNode;
}

export function Card({
  title,
  subtitle,
  actions,
  className,
  children,
  ...props
}: CardProps) {
  return (
    <section className={classNames("card", className)} {...props}>
      {(title || subtitle || actions) && (
        <div className="card__header">
          <div>
            {title ? <h3 className="card__title">{title}</h3> : null}
            {subtitle ? <p className="card__subtitle">{subtitle}</p> : null}
          </div>
          {actions ? <div className="card__actions">{actions}</div> : null}
        </div>
      )}
      {children}
    </section>
  );
}