import { useEffect, useMemo, useState } from "react";
import { Badge } from "../../components/ui/Badge";
import { Button } from "../../components/ui/Button";
import { Card } from "../../components/ui/Card";
import { DataTable } from "../../components/ui/DataTable";
import { InputField, SelectField, TextAreaField } from "../../components/ui/Field";
import { PageHeader } from "../../components/ui/PageHeader";
import { formatDateTime, getApiErrorMessage, getBloodTypeLabel } from "../../lib/helpers";
import { demandeService } from "../../services/demande.service";
import { Loader } from "../../components/ui/Loader";
import type { DemandePayload, DemandeSang, TypeSanguin } from "../../types";
import { typeService } from "../../services/type.service";
import { useAuth } from "../../contexts/useAuth";

type FormState = {
  quantite: string;
  urgence: boolean;
  contactNom: string;
  typeSanguinId: string;
  raisonDemande: string;
  notesComplementaires: string;
};

const initialForm: FormState = {
  quantite: "1",
  urgence: false,
  contactNom: "",
  typeSanguinId: "",
  raisonDemande: "",
  notesComplementaires: ""
};

export function DemandesPage() {
  const { user } = useAuth();
  const [demandes, setDemandes] = useState<DemandeSang[]>([]);
  const [types, setTypes] = useState<TypeSanguin[]>([]);
  const [form, setForm] = useState<FormState>(initialForm);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [urgentOnly, setUrgentOnly] = useState(false);

  async function load() {
    setLoading(true);
    setError("");

    try {
      const [demandesData, bloodTypes] = await Promise.all([
        demandeService.getAll(),
        typeService.getBloodTypes()
      ]);

      setDemandes(demandesData);
      setTypes(bloodTypes);
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
      const payload: DemandePayload = {
        quantite: Number(form.quantite),
        urgence: form.urgence,
        contactNom: form.contactNom,
        raisonDemande: form.raisonDemande || undefined,
        notesComplementaires: form.notesComplementaires || undefined,
        typeSanguinId: form.typeSanguinId
          ? Number(form.typeSanguinId)
          : undefined
      };

      await demandeService.create(payload);
      setForm(initialForm);
      await load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  async function handleStatusUpdate(demande: DemandeSang) {
    const nextStatus = window.prompt(
      "Nouveau statut (mettre la valeur exacte de ton enum backend)",
      demande.statut
    );

    if (!nextStatus || nextStatus.trim() === "") return;

    try {
      await demandeService.updateStatus(demande.id, nextStatus.trim());
      await load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  async function handleDelete(id: number) {
    if (user?.role !== "ADMIN") return;

    const confirmed = window.confirm("Supprimer cette demande ?");
    if (!confirmed) return;

    try {
      await demandeService.remove(id);
      await load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  const visibleDemandes = useMemo(() => {
    return urgentOnly
      ? demandes.filter((demande) => demande.urgence)
      : demandes;
  }, [demandes, urgentOnly]);

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Demandes de sang"
        description="Création et suivi rapide des demandes."
        actions={
          <Button
            variant={urgentOnly ? "danger" : "secondary"}
            onClick={() => setUrgentOnly((prev) => !prev)}
          >
            {urgentOnly ? "Voir toutes" : "Voir urgentes"}
          </Button>
        }
      />

      {error ? <div className="alert alert--error">{error}</div> : null}

      <Card title="Créer une demande">
        <form onSubmit={handleCreate} className="stack">
          <div className="grid-three">
            <InputField
              label="Quantité"
              type="number"
              min={1}
              value={form.quantite}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, quantite: e.target.value }))
              }
              required
            />

            <InputField
              label="Contact"
              value={form.contactNom}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, contactNom: e.target.value }))
              }
              required
            />

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
            />
          </div>

          <TextAreaField
            label="Raison"
            rows={2}
            value={form.raisonDemande}
            onChange={(e) =>
              setForm((prev) => ({ ...prev, raisonDemande: e.target.value }))
            }
          />

          <TextAreaField
            label="Notes complémentaires"
            rows={2}
            value={form.notesComplementaires}
            onChange={(e) =>
              setForm((prev) => ({
                ...prev,
                notesComplementaires: e.target.value
              }))
            }
          />

          <label className="checkbox-line">
            <input
              type="checkbox"
              checked={form.urgence}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, urgence: e.target.checked }))
              }
            />
            <span>Demande urgente</span>
          </label>

          <Button type="submit" disabled={saving}>
            {saving ? "Création..." : "Créer la demande"}
          </Button>
        </form>
      </Card>

      <Card title="Demandes enregistrées">
        <DataTable
          data={visibleDemandes}
          columns={[
            {
              header: "Contact",
              accessor: "contactNom"
            },
            {
              header: "Type",
              render: (row) => getBloodTypeLabel(row)
            },
            {
              header: "Quantité",
              render: (row) => row.quantite
            },
            {
              header: "Urgence",
              render: (row) => (
                <Badge variant={row.urgence ? "danger" : "default"}>
                  {row.urgence ? "Urgente" : "Normale"}
                </Badge>
              )
            },
            {
              header: "Statut",
              render: (row) => <Badge variant="info">{row.statut}</Badge>
            },
            {
              header: "Créée le",
              render: (row) => formatDateTime(row.dateCreation)
            },
            {
              header: "Actions",
              render: (row) => (
                <div className="inline-actions">
                  <Button
                    variant="secondary"
                    onClick={() => handleStatusUpdate(row)}
                  >
                    Statut
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