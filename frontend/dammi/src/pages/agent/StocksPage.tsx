import { useEffect, useMemo, useState } from "react";
import type { PointCollecte, StockPayload, StockSanguin, TypeSanguin } from "../../types";
import { stockService } from "../../services/stock.service";
import { typeService } from "../../services/type.service";
import { pointCollecteService } from "../../services/pointCollecte.service";
import { getApiErrorMessage, getBloodTypeLabel, getPointCollecteName, isStockAlert } from "../../lib/helpers";
import { Loader } from "../../components/ui/Loader";
import { PageHeader } from "../../components/ui/PageHeader";
import { Card } from "../../components/ui/Card";
import { InputField, SelectField } from "../../components/ui/Field";
import { Button } from "../../components/ui/Button";
import { DataTable } from "../../components/ui/DataTable";
import { Badge } from "../../components/ui/Badge";
import { useAuth } from "../../contexts/useAuth";

type FormState = {
  quantiteDisponible: string;
  seuilMinimum: string;
  typeSanguinId: string;
  pointCollecteId: string;
};

const initialForm: FormState = {
  quantiteDisponible: "0",
  seuilMinimum: "10",
  typeSanguinId: "",
  pointCollecteId: ""
};

export function StocksPage() {
  const { user } = useAuth();
  const [stocks, setStocks] = useState<StockSanguin[]>([]);
  const [types, setTypes] = useState<TypeSanguin[]>([]);
  const [points, setPoints] = useState<PointCollecte[]>([]);
  const [form, setForm] = useState<FormState>(initialForm);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  async function load() {
    setLoading(true);
    setError("");

    try {
      const [stocksData, typesData, pointsData] = await Promise.all([
        stockService.getAll(),
        typeService.getBloodTypes(),
        pointCollecteService.getAll()
      ]);

      setStocks(stocksData);
      setTypes(typesData);
      setPoints(pointsData);
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError("");

    try {
      const payload: StockPayload = {
        quantiteDisponible: Number(form.quantiteDisponible),
        seuilMinimum: Number(form.seuilMinimum),
        typeSanguinId: Number(form.typeSanguinId)
      };

      if (form.pointCollecteId) {
        payload.pointCollecteId = Number(form.pointCollecteId);
      }

      await stockService.create(payload);
      setForm(initialForm);
      await load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  async function handleUpdateQuantity(stock: StockSanguin) {
    const nextValue = window.prompt(
      "Nouvelle quantité disponible",
      String(stock.quantiteDisponible)
    );

    if (nextValue === null || nextValue.trim() === "") return;

    try {
      await stockService.updateQuantity(stock.id, Number(nextValue));
      await load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  async function handleDelete(id: number) {
    if (user?.role !== "ADMIN") return;

    const confirmed = window.confirm("Supprimer ce stock ?");
    if (!confirmed) return;

    try {
      await stockService.remove(id);
      await load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  const filteredStocks = useMemo(() => {
    return stocks.filter((stock) => {
      const search = query.toLowerCase();
      return (
        getBloodTypeLabel(stock).toLowerCase().includes(search) ||
        getPointCollecteName(stock).toLowerCase().includes(search)
      );
    });
  }, [stocks, query]);

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Stocks sanguins"
        description="Créer, consulter et ajuster rapidement les quantités."
      />

      {error ? <div className="alert alert--error">{error}</div> : null}

      <Card title="Créer un stock">
        <form onSubmit={handleCreate} className="stack">
          <div className="grid-two">
            <SelectField
              label="Type sanguin"
              value={form.typeSanguinId}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, typeSanguinId: e.target.value }))
              }
              options={[
                { label: "Sélectionner un type", value: "" },
                ...types.map((type) => ({
                  label: type.aboGroup || type.label || `Type ${type.id}`,
                  value: type.id
                }))
              ]}
              required
            />

            <SelectField
              label="Point de collecte"
              value={form.pointCollecteId}
              onChange={(e) =>
                setForm((prev) => ({
                  ...prev,
                  pointCollecteId: e.target.value
                }))
              }
              options={[
                { label: "Aucun point spécifique", value: "" },
                ...points.map((point) => ({
                  label: `${point.nom} - ${point.ville}`,
                  value: point.id
                }))
              ]}
            />
          </div>

          <div className="grid-two">
            <InputField
              label="Quantité disponible"
              type="number"
              min={0}
              value={form.quantiteDisponible}
              onChange={(e) =>
                setForm((prev) => ({
                  ...prev,
                  quantiteDisponible: e.target.value
                }))
              }
              required
            />

            <InputField
              label="Seuil minimum"
              type="number"
              min={0}
              value={form.seuilMinimum}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, seuilMinimum: e.target.value }))
              }
              required
            />
          </div>

          <Button type="submit" disabled={saving}>
            {saving ? "Création..." : "Créer le stock"}
          </Button>
        </form>
      </Card>

      <Card
        title="Liste des stocks"
        actions={
          <div className="search-box">
            <input
              className="input"
              placeholder="Rechercher par type ou centre..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
        }
      >
        <DataTable
          data={filteredStocks}
          columns={[
            {
              header: "Groupe",
              render: (row) => getBloodTypeLabel(row)
            },
            {
              header: "Point",
              render: (row) => getPointCollecteName(row)
            },
            {
              header: "Disponible",
              render: (row) => row.quantiteDisponible
            },
            {
              header: "Seuil",
              render: (row) => row.seuilMinimum
            },
            {
              header: "État",
              render: (row) => (
                <Badge variant={isStockAlert(row) ? "danger" : "success"}>
                  {isStockAlert(row) ? "Sous seuil" : "Normal"}
                </Badge>
              )
            },
            {
              header: "Actions",
              render: (row) => (
                <div className="inline-actions">
                  <Button
                    variant="secondary"
                    onClick={() => handleUpdateQuantity(row)}
                  >
                    Ajuster
                  </Button>

                  {user?.role === "ADMIN" ? (
                    <Button
                      variant="danger"
                      onClick={() => handleDelete(row.id)}
                    >
                      Supprimer
                    </Button>
                  ) : null}
                </div>
              )
            }
          ]}
        />
      </Card>
    </div>
  );
}