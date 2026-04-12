import { useEffect, useState } from "react";
import type { Question, QuestionPayload, QuestionTypeReponse } from "../../types";
import { questionService } from "../../services/question.service";
import { getApiErrorMessage } from "../../lib/helpers";
import { PageHeader } from "../../components/ui/PageHeader";
import { Button } from "../../components/ui/Button";
import { Loader } from "../../components/ui/Loader";
import { Card } from "../../components/ui/Card";
import { InputField, TextAreaField } from "../../components/ui/Field";
import { DataTable } from "../../components/ui/DataTable";

type OptionForm = {
  label: string;
  value: string;
  ordre: number;
  bloquante: boolean;
  active: boolean;
};

type FormState = {
  texte: string;
  typeReponse: QuestionTypeReponse;
  aide: string;
  actif: boolean;
  options: OptionForm[];
};

const emptyOption = (ordre = 1): OptionForm => ({
  label: "",
  value: "",
  ordre,
  bloquante: false,
  active: true
});

const yesNoOptions = (): OptionForm[] => [
  { label: "Oui", value: "OUI", ordre: 1, bloquante: true, active: true },
  { label: "Non", value: "NON", ordre: 2, bloquante: false, active: true }
];

const initialForm: FormState = {
  texte: "",
  typeReponse: "YES_NO",
  aide: "",
  actif: true,
  options: yesNoOptions()
};

const choiceTypes: QuestionTypeReponse[] = ["YES_NO", "SINGLE_CHOICE", "MULTIPLE_CHOICE"];

export function AdminQuestionsPage() {
  const [items, setItems] = useState<Question[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [form, setForm] = useState<FormState>(initialForm);

  async function loadQuestions() {
    const data = await questionService.getAll();
    setItems(data);
  }

  useEffect(() => {
    async function init() {
      setLoading(true);
      setError("");

      try {
        await loadQuestions();
      } catch (err) {
        setError(getApiErrorMessage(err));
      } finally {
        setLoading(false);
      }
    }

    void init();
  }, []);

  function resetForm() {
    setEditingId(null);
    setForm(initialForm);
    setError("");
    setSuccess("");
  }

  function handleTypeChange(value: QuestionTypeReponse) {
    setForm((prev) => {
      if (value === "YES_NO") {
        return { ...prev, typeReponse: value, options: yesNoOptions() };
      }

      if (value === "SINGLE_CHOICE" || value === "MULTIPLE_CHOICE") {
        return {
          ...prev,
          typeReponse: value,
          options: prev.options.length > 0 ? prev.options : [emptyOption(1)]
        };
      }

      return {
        ...prev,
        typeReponse: value,
        options: []
      };
    });
  }

  function addOption() {
    setForm((prev) => ({
      ...prev,
      options: [...prev.options, emptyOption(prev.options.length + 1)]
    }));
  }

  function updateOption(index: number, patch: Partial<OptionForm>) {
    setForm((prev) => ({
      ...prev,
      options: prev.options.map((option, i) =>
        i === index ? { ...option, ...patch } : option
      )
    }));
  }

  function removeOption(index: number) {
    setForm((prev) => ({
      ...prev,
      options: prev.options.filter((_, i) => i !== index)
    }));
  }

  function mapPayload(state: FormState): QuestionPayload {
    return {
      texte: state.texte,
      typeReponse: state.typeReponse,
      aide: state.aide || undefined,
      actif: state.actif,
      options: choiceTypes.includes(state.typeReponse)
        ? state.options.map((option) => ({
            label: option.label,
            value: option.value,
            ordre: option.ordre,
            bloquante: option.bloquante,
            active: option.active
          }))
        : []
    };
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError("");
    setSuccess("");

    try {
      const payload = mapPayload(form);

      if (editingId) {
        await questionService.update(editingId, payload);
        setSuccess("Question modifiée avec succès.");
      } else {
        await questionService.create(payload);
        setSuccess("Question créée avec succès.");
      }

      resetForm();
      await loadQuestions();
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  function handleEdit(question: Question) {
    setEditingId(question.id);
    setSuccess("");
    setForm({
      texte: question.texte,
      typeReponse: question.typeReponse,
      aide: question.aide || "",
      actif: question.actif,
      options: (question.options || []).map((option) => ({
        label: option.label,
        value: option.value,
        ordre: option.ordre,
        bloquante: option.bloquante,
        active: option.active
      }))
    });
  }

  async function handleDelete(id: number) {
    const confirmed = window.confirm("Supprimer cette question ?");
    if (!confirmed) return;

    try {
      await questionService.remove(id);
      await loadQuestions();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Banque de questions"
        description="Créer les questions, définir leur type de réponse et les options bloquantes."
        actions={
          <Button variant="secondary" type="button" onClick={resetForm}>
            Nouvelle question
          </Button>
        }
      />

      {error ? <div className="alert alert--error">{error}</div> : null}
      {success ? <div className="alert alert--success">{success}</div> : null}

      <Card
        title={editingId ? "Modifier une question" : "Ajouter une question"}
        subtitle="Les questions YES/NO, SINGLE_CHOICE et MULTIPLE_CHOICE utilisent des options."
      >
        <form onSubmit={handleSubmit} className="stack">
          <TextAreaField
            label="Texte de la question"
            rows={3}
            value={form.texte}
            onChange={(e) => setForm((prev) => ({ ...prev, texte: e.target.value }))}
          />

          <div className="grid-two">
            <div>
              <label className="field__label">Type de réponse</label>
              <select
                className="input"
                value={form.typeReponse}
                onChange={(e) => handleTypeChange(e.target.value as QuestionTypeReponse)}
              >
                <option value="YES_NO">Oui / Non</option>
                <option value="SINGLE_CHOICE">Choix unique</option>
                <option value="MULTIPLE_CHOICE">Choix multiple</option>
                <option value="TEXT">Texte</option>
                <option value="NUMBER">Nombre</option>
                <option value="DATE">Date</option>
              </select>
            </div>

            <InputField
              label="Aide"
              value={form.aide}
              onChange={(e) => setForm((prev) => ({ ...prev, aide: e.target.value }))}
            />
          </div>

          <label style={{ display: "flex", gap: 8, alignItems: "center" }}>
            <input
              type="checkbox"
              checked={form.actif}
              onChange={(e) => setForm((prev) => ({ ...prev, actif: e.target.checked }))}
            />
            <span>Question active</span>
          </label>

          {choiceTypes.includes(form.typeReponse) ? (
            <Card
              title="Options de réponse"
              actions={
                form.typeReponse !== "YES_NO" ? (
                  <Button type="button" variant="secondary" onClick={addOption}>
                    Ajouter une option
                  </Button>
                ) : null
              }
            >
              <div className="stack">
                {form.options.map((option, index) => (
                  <div key={index} className="card" style={{ padding: 16 }}>
                    <div className="grid-two">
                      <InputField
                        label="Label"
                        value={option.label}
                        onChange={(e) => updateOption(index, { label: e.target.value })}
                      />

                      <InputField
                        label="Valeur"
                        value={option.value}
                        onChange={(e) => updateOption(index, { value: e.target.value })}
                      />
                    </div>

                    <div className="grid-two">
                      <InputField
                        label="Ordre"
                        type="number"
                        value={String(option.ordre)}
                        onChange={(e) =>
                          updateOption(index, { ordre: Number(e.target.value) || 0 })
                        }
                      />

                      <div style={{ display: "flex", gap: 20, alignItems: "end", paddingBottom: 12 }}>
                        <label style={{ display: "flex", gap: 8, alignItems: "center" }}>
                          <input
                            type="checkbox"
                            checked={option.bloquante}
                            onChange={(e) =>
                              updateOption(index, { bloquante: e.target.checked })
                            }
                          />
                          <span>Réponse bloquante</span>
                        </label>

                        <label style={{ display: "flex", gap: 8, alignItems: "center" }}>
                          <input
                            type="checkbox"
                            checked={option.active}
                            onChange={(e) => updateOption(index, { active: e.target.checked })}
                          />
                          <span>Option active</span>
                        </label>
                      </div>
                    </div>

                    {form.typeReponse !== "YES_NO" ? (
                      <Button
                        type="button"
                        variant="danger"
                        onClick={() => removeOption(index)}
                      >
                        Supprimer l’option
                      </Button>
                    ) : null}
                  </div>
                ))}
              </div>
            </Card>
          ) : null}

          <div className="inline-actions">
            <Button type="submit" disabled={saving}>
              {saving
                ? "Enregistrement..."
                : editingId
                ? "Mettre à jour"
                : "Créer la question"}
            </Button>

            {editingId ? (
              <Button type="button" variant="secondary" onClick={resetForm}>
                Annuler
              </Button>
            ) : null}
          </div>
        </form>
      </Card>

      <Card title="Questions enregistrées">
        <DataTable
          data={items}
          columns={[
            { header: "Texte", accessor: "texte" },
            { header: "Type", render: (row) => row.typeReponse },
            { header: "Actif", render: (row) => (row.actif ? "Oui" : "Non") },
            {
              header: "Options",
              render: (row) => row.options?.length ?? 0
            },
            {
              header: "Actions",
              render: (row) => (
                <div className="inline-actions">
                  <Button type="button" variant="secondary" onClick={() => handleEdit(row)}>
                    Éditer
                  </Button>
                  <Button type="button" variant="danger" onClick={() => handleDelete(row.id)}>
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