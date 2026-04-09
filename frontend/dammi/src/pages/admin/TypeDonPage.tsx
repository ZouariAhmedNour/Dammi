import { useEffect, useState } from "react";
import type { TypeDon, TypeDonPayload } from "../../types";
import { typeService } from "../../services/type.service";
import { getApiErrorMessage } from "../../lib/helpers";
import { Loader } from "../../components/ui/Loader";
import { PageHeader } from "../../components/ui/PageHeader";
import { Button } from "../../components/ui/Button";
import { StatCard } from "../../components/ui/StatCard";
import { Card } from "../../components/ui/Card";
import { InputField } from "../../components/ui/Field";
import { DataTable } from "../../components/ui/DataTable";


const initialForm: TypeDonPayload = {
  label: ""
};

export function AdminTypeDonPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [items, setItems] = useState<TypeDon[]>([]);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [form, setForm] = useState<TypeDonPayload>(initialForm);

  async function loadTypes() {
    setLoading(true);
    setError("");

    try {
      const data = await typeService.getDonationTypes();
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

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError("");

    try {
      const payload: TypeDonPayload = {
        label: form.label.trim()
      };

      if (editingId) {
        await typeService.updateDonationType(editingId, payload);
      } else {
        await typeService.createDonationType(payload);
      }

      resetForm();
      await loadTypes();
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  function handleEdit(item: TypeDon) {
    setEditingId(item.id);
    setForm({
      label: item.label
    });
  }

  async function handleDelete(id: number) {
    const confirmed = window.confirm("Voulez-vous vraiment supprimer ce type de don ?");
    if (!confirmed) return;

    try {
      await typeService.deleteDonationType(id);

      if (editingId === id) {
        resetForm();
      }

      await loadTypes();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Types de don"
        description="Ajout, modification et suppression des types de don."
        actions={
          <Button type="button" variant="secondary" onClick={resetForm}>
            Nouveau type
          </Button>
        }
      />

      {error ? <div className="alert alert--error">{error}</div> : null}

      <div className="stats-grid">
        <StatCard label="Total" value={items.length} />
        <StatCard
          label="En édition"
          value={editingId ? "Oui" : "Non"}
          tone={editingId ? "success" : "default"}
        />
      </div>

      <div className="content-grid">
        <Card
          title={editingId ? "Modifier le type de don" : "Ajouter un type de don"}
          subtitle="Exemples : Sang complet, Plasma, Plaquettes"
        >
          <form onSubmit={handleSubmit}>
            <div style={{ display: "grid", gap: 16 }}>
              <InputField
                label="Libellé"
                placeholder="Ex: Sang complet"
                value={form.label}
                onChange={(e) =>
                  setForm((prev) => ({ ...prev, label: e.target.value }))
                }
                required
              />

              <div style={{ display: "flex", gap: 12, flexWrap: "wrap" }}>
                <Button type="submit" disabled={saving}>
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
          title="Liste des types de don"
          subtitle={`${items.length} type(s) configuré(s)`}
        >
          <DataTable
            data={items}
            emptyMessage="Aucun type de don trouvé"
            columns={[
              {
                header: "ID",
                render: (row) => row.id
              },
              {
                header: "Libellé",
                accessor: "label"
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