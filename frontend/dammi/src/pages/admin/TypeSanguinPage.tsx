import { useEffect, useState } from "react";
import type { TypeSanguin, TypeSanguinPayload } from "../../types";
import { typeService } from "../../services/type.service";
import { getApiErrorMessage } from "../../lib/helpers";
import { Loader } from "lucide-react";
import { PageHeader } from "../../components/ui/PageHeader";
import { Button } from "../../components/ui/Button";
import { StatCard } from "../../components/ui/StatCard";
import { Card } from "../../components/ui/Card";
import { InputField, SelectField } from "../../components/ui/Field";
import { DataTable } from "../../components/ui/DataTable";
import { Badge } from "../../components/ui/Badge";

const bloodOptions = [
  { label: "Sélectionner un groupe", value: "" },
  { label: "A+", value: "A+" },
  { label: "A-", value: "A-" },
  { label: "B+", value: "B+" },
  { label: "B-", value: "B-" },
  { label: "AB+", value: "AB+" },
  { label: "AB-", value: "AB-" },
  { label: "O+", value: "O+" },
  { label: "O-", value: "O-" }
];

const initialForm: TypeSanguinPayload = {
  label: "",
  aboGroup: ""
};

export function AdminTypeSanguinPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [items, setItems] = useState<TypeSanguin[]>([]);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [form, setForm] = useState<TypeSanguinPayload>(initialForm);

  async function loadTypes() {
    setLoading(true);
    setError("");

    try {
      const data = await typeService.getBloodTypes();
      setItems(data);
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void loadTypes();
  }, []);

  function resetForm() {
    setForm(initialForm);
    setEditingId(null);
    setError("");
  }

  function handleGroupChange(value: string) {
    setForm({
      label: value,
      aboGroup: value
    });
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError("");

    try {
      const payload: TypeSanguinPayload = {
        label: form.label.trim(),
        aboGroup: form.aboGroup.trim()
      };

      if (editingId) {
        await typeService.updateBloodType(editingId, payload);
      } else {
        await typeService.createBloodType(payload);
      }

      resetForm();
      await loadTypes();
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  function handleEdit(item: TypeSanguin) {
    setEditingId(item.id);
    setForm({
      label: item.label ?? item.aboGroup ?? "",
      aboGroup: item.aboGroup ?? ""
    });
  }

  async function handleDelete(id: number) {
    const confirmed = window.confirm(
      "Voulez-vous vraiment supprimer ce type sanguin ?"
    );
    if (!confirmed) return;

    try {
      await typeService.deleteBloodType(id);

      if (editingId === id) {
        resetForm();
      }

      await loadTypes();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  const positiveCount = items.filter((item) => item.aboGroup?.endsWith("+")).length;
  const negativeCount = items.filter((item) => item.aboGroup?.endsWith("-")).length;

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Types sanguins"
        description="Configuration des groupes ABO disponibles dans l’application."
        actions={
          <Button type="button" variant="secondary" onClick={resetForm}>
            Nouveau type
          </Button>
        }
      />

      {error ? <div className="alert alert--error">{error}</div> : null}

      <div className="stats-grid">
        <StatCard label="Total" value={items.length} />
        <StatCard label="Rhésus positif" value={positiveCount} tone="success" />
        <StatCard label="Rhésus négatif" value={negativeCount} />
      </div>

      <div className="content-grid">
        <Card
          title={editingId ? "Modifier le type sanguin" : "Ajouter un type sanguin"}
          subtitle="Le libellé est synchronisé avec le groupe ABO."
        >
          <form onSubmit={handleSubmit}>
            <div style={{ display: "grid", gap: 16 }}>
              <SelectField
                label="Groupe ABO"
                value={form.aboGroup}
                options={bloodOptions}
                onChange={(e) => handleGroupChange(e.target.value)}
                required
              />

              <InputField
                label="Libellé"
                value={form.label}
                readOnly
                hint="Synchronisé automatiquement avec le groupe ABO."
              />

              <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
                <Button type="submit" disabled={saving || !form.aboGroup}>
                  {saving
                    ? "Enregistrement..."
                    : editingId
                    ? "Mettre à jour"
                    : "Ajouter"}
                </Button>

                {editingId ? (
                  <Button type="button" variant="ghost" onClick={resetForm}>
                    Annuler
                  </Button>
                ) : null}
              </div>
            </div>
          </form>
        </Card>

        <Card
          title="Liste des types sanguins"
          subtitle={`${items.length} type(s) configuré(s)`}
        >
          <DataTable
            data={items}
            emptyMessage="Aucun type sanguin trouvé"
            columns={[
              {
                header: "ID",
                render: (row) => row.id
              },
              {
                header: "Libellé",
                render: (row) => row.label || "-"
              },
              {
                header: "Groupe ABO",
                render: (row) => (
                  <Badge variant="info">{row.aboGroup || "-"}</Badge>
                )
              },
              {
                header: "Actions",
                render: (row) => (
                  <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
                    <Button
                      type="button"
                      variant="secondary"
                      onClick={() => handleEdit(row)}
                    >
                      Modifier
                    </Button>
                    <Button
                      type="button"
                      variant="danger"
                      onClick={() => handleDelete(row.id)}
                    >
                      Supprimer
                    </Button>
                  </div>
                )
              }
            ]}
          />
        </Card>
      </div>
    </div>
  );
}