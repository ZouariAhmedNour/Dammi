import axios from "axios";

type DisplayUser = {
  prenom?: string;
  nom?: string;
  email?: string;
};

type BloodTypeRef = {
  aboGroup?: string;
  label?: string;
};

type BloodTypeSource = {
  typeSanguin?: BloodTypeRef;
  typeSanguinLabel?: string;
  aboGroup?: string;
  label?: string;
  typeSanguinId?: number | string;
};

type PointCollecteRef = {
  nom?: string;
};

type PointCollecteSource = {
  pointCollecte?: PointCollecteRef;
  pointCollecteNom?: string;
  nomPointCollecte?: string;
  nom?: string;
  pointCollecteId?: number | string;
};

type StockLike = {
  quantiteDisponible?: number | string;
  seuilMinimum?: number | string;
};

export function classNames(
  ...values: Array<string | false | null | undefined>
) {
  return values.filter(Boolean).join(" ");
}

export function formatDate(value?: string | null) {
  if (!value) return "-";

  const normalized = value.length === 10 ? `${value}T00:00:00` : value;
  const date = new Date(normalized);

  if (Number.isNaN(date.getTime())) return value;

  return date.toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "short",
    year: "numeric"
  });
}

export function formatDateTime(value?: string | null) {
  if (!value) return "-";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) return value;

  return date.toLocaleString("fr-FR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit"
  });
}

export function getApiErrorMessage(error: unknown) {
  if (axios.isAxiosError(error)) {
    const data = error.response?.data as
      | { message?: string; error?: string }
      | undefined;

    return data?.message ?? data?.error ?? error.message ?? "Erreur API";
  }

  if (error instanceof Error) return error.message;

  return "Une erreur est survenue.";
}

export function getUserDisplayName(user?: DisplayUser) {
  const fullName = [user?.prenom, user?.nom].filter(Boolean).join(" ").trim();
  return fullName || user?.email || "Inconnu";
}

export function getBloodTypeLabel(source?: BloodTypeSource) {
  return (
    source?.typeSanguin?.aboGroup ??
    source?.typeSanguin?.label ??
    source?.typeSanguinLabel ??
    source?.aboGroup ??
    source?.label ??
    (source?.typeSanguinId ? `Type #${source.typeSanguinId}` : "-")
  );
}

export function getPointCollecteName(source?: PointCollecteSource) {
  return (
    source?.pointCollecte?.nom ??
    source?.pointCollecteNom ??
    source?.nomPointCollecte ??
    source?.nom ??
    (source?.pointCollecteId ? `Point #${source.pointCollecteId}` : "-")
  );
}

export function isStockAlert(stock?: StockLike) {
  if (!stock) return false;
  return Number(stock.quantiteDisponible) <= Number(stock.seuilMinimum);
}