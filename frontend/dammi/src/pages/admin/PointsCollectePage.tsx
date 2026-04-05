import { useEffect, useMemo, useState } from "react";
import type { PointCollecte, PointCollectePayload } from "../../types";
import { pointCollecteService } from "../../services/pointCollecte.service";
import { getApiErrorMessage } from "../../lib/helpers";
import { Loader } from "../../components/ui/Loader";
import { PageHeader } from "../../components/ui/PageHeader";
import { Card } from "../../components/ui/Card";
import { InputField, TextAreaField } from "../../components/ui/Field";
import { Button } from "../../components/ui/Button";
import { DataTable } from "../../components/ui/DataTable";

type FormState = {
  nom: string;
  adresse: string;
  ville: string;
  capacite: string;
  telephone: string;
  latitude: string;
  longitude: string;
  description: string;
};

const initialForm: FormState = {
  nom: "",
  adresse: "",
  ville: "",
  capacite: "10",
  telephone: "",
  latitude: "0",
  longitude: "0",
  description: ""
};

export function PointsCollectePage() {
  const [points, setPoints] = useState<PointCollecte[]>([]);
  const [form, setForm] = useState<FormState>(initialForm);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  async function load() {
    setLoading(true);
    setError("");

    try {
      const data = await pointCollecteService.getAll();
      setPoints(data);
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  function mapFormToPayload(state: FormState): PointCollectePayload {
    return {
      nom: state.nom,
      adresse: state.adresse,
      ville: state.ville,
      capacite: Number(state.capacite),
      telephone: state.telephone || undefined,
      latitude: Number(state.latitude),
      longitude: Number(state.longitude),
      description: state.description || undefined
    };
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError("");

    try {
      const payload = mapFormToPayload(form);

      if (editingId) {
        await pointCollecteService.update(editingId, payload);
      } else {
        await pointCollecteService.create(payload);
      }

      setForm(initialForm);
      setEditingId(null);
      await load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  function handleEdit(point: PointCollecte) {
    setEditingId(point.id);
    setForm({
      nom: point.nom,
      adresse: point.adresse,
      ville: point.ville,
      capacite: String(point.capacite),
      telephone: point.telephone || "",
      latitude: String(point.latitude ?? 0),
      longitude: String(point.longitude ?? 0),
      description: point.description || ""
    });
  }

  async function handleDelete(id: number) {
    const confirmed = window.confirm("Supprimer ce point de collecte ?");
    if (!confirmed) return;

    try {
      await pointCollecteService.remove(id);
      await load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  const filteredPoints = useMemo(() => {
    return points.filter((point) => {
      const search = query.toLowerCase();
      return (
        point.nom.toLowerCase().includes(search) ||
        point.ville.toLowerCase().includes(search) ||
        point.adresse.toLowerCase().includes(search)
      );
    });
  }, [points, query]);

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Points de collecte"
        description="Création et gestion des centres de collecte."
      />

      {error ? <div className="alert alert--error">{error}</div> : null}

      <Card
        title={editingId ? "Modifier un point" : "Ajouter un point"}
        subtitle="Formulaire réutilisable pour la création et la mise à jour."
      >
        <form onSubmit={handleSubmit} className="stack">
          <div className="grid-two">
            <InputField
              label="Nom"
              value={form.nom}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, nom: e.target.value }))
              }
              required
            />
            <InputField
              label="Ville"
              value={form.ville}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, ville: e.target.value }))
              }
              required
            />
          </div>

          <InputField
            label="Adresse"
            value={form.adresse}
            onChange={(e) =>
              setForm((prev) => ({ ...prev, adresse: e.target.value }))
            }
            required
          />

          <div className="grid-three">
            <InputField
              label="Capacité"
              type="number"
              min={1}
              value={form.capacite}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, capacite: e.target.value }))
              }
              required
            />
            <InputField
              label="Téléphone"
              value={form.telephone}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, telephone: e.target.value }))
              }
            />
            <InputField
              label="Latitude"
              type="number"
              step="0.000001"
              value={form.latitude}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, latitude: e.target.value }))
              }
            />
          </div>

          <div className="grid-two">
            <InputField
              label="Longitude"
              type="number"
              step="0.000001"
              value={form.longitude}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, longitude: e.target.value }))
              }
            />
            <div />
          </div>

          <TextAreaField
            label="Description"
            rows={3}
            value={form.description}
            onChange={(e) =>
              setForm((prev) => ({ ...prev, description: e.target.value }))
            }
          />

          <div className="inline-actions">
            <Button type="submit" disabled={saving}>
              {saving
                ? "Enregistrement..."
                : editingId
                ? "Mettre à jour"
                : "Créer le point"}
            </Button>

            {editingId ? (
              <Button
                type="button"
                variant="secondary"
                onClick={() => {
                  setEditingId(null);
                  setForm(initialForm);
                }}
              >
                Annuler
              </Button>
            ) : null}
          </div>
        </form>
      </Card>

      <Card
        title="Centres enregistrés"
        actions={
          <div className="search-box">
            <input
              className="input"
              placeholder="Recherche par nom, ville..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
        }
      >
        <DataTable
          data={filteredPoints}
          columns={[
            { header: "Nom", accessor: "nom" },
            { header: "Ville", accessor: "ville" },
            { header: "Adresse", accessor: "adresse" },
            { header: "Capacité", accessor: "capacite" },
            {
              header: "Actions",
              render: (point) => (
                <div className="inline-actions">
                  <Button
                    variant="secondary"
                    onClick={() => handleEdit(point)}
                  >
                    Éditer
                  </Button>
                  <Button
                    variant="danger"
                    onClick={() => handleDelete(point.id)}
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
  );
}