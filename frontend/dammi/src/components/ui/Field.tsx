import type { InputHTMLAttributes, SelectHTMLAttributes, TextareaHTMLAttributes } from "react";

export interface FieldOption {
  label: string;
  value: string | number;
}

interface BaseFieldProps {
  label: string;
  hint?: string;
}

type InputFieldProps = BaseFieldProps & InputHTMLAttributes<HTMLInputElement>;
type SelectFieldProps = BaseFieldProps &
  SelectHTMLAttributes<HTMLSelectElement> & {
    options: FieldOption[];
  };
type TextAreaFieldProps = BaseFieldProps &
  TextareaHTMLAttributes<HTMLTextAreaElement>;

export function InputField({ label, hint, ...props }: InputFieldProps) {
  return (
    <label className="field">
      <span className="field__label">{label}</span>
      <input className="input" {...props} />
      {hint ? <span className="field__hint">{hint}</span> : null}
    </label>
  );
}

export function SelectField({
  label,
  hint,
  options,
  ...props
}: SelectFieldProps) {
  return (
    <label className="field">
      <span className="field__label">{label}</span>
      <select className="input" {...props}>
        {options.map((option) => (
          <option key={`${option.value}`} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
      {hint ? <span className="field__hint">{hint}</span> : null}
    </label>
  );
}

export function TextAreaField({
  label,
  hint,
  ...props
}: TextAreaFieldProps) {
  return (
    <label className="field">
      <span className="field__label">{label}</span>
      <textarea className="input textarea" {...props} />
      {hint ? <span className="field__hint">{hint}</span> : null}
    </label>
  );
}