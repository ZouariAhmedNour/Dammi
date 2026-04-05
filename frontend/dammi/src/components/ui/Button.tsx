import type { ButtonHTMLAttributes } from "react";
import { classNames } from "../../lib/helpers";

type Variant = "primary" | "secondary" | "danger" | "ghost";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  block?: boolean;
}

export function Button({
  variant = "primary",
  block = false,
  className,
  children,
  ...props
}: ButtonProps) {
  return (
    <button
      className={classNames(
        "button",
        `button--${variant}`,
        block && "button--block",
        className
      )}
      {...props}
    >
      {children}
    </button>
  );
}