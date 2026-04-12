import { useEffect, useMemo, useState } from "react";
import type {
  Question,
  Questionnaire,
  QuestionnairePayload,
  QuestionnaireType
} from "../../types";
import { questionnaireService } from "../../services/questionnaire.service";
import { questionService } from "../../services/question.service";
import { getApiErrorMessage } from "../../lib/helpers";
import { PageHeader } from "../../components/ui/PageHeader";
import { Loader } from "../../components/ui/Loader";
import { Card } from "../../components/ui/Card";
import { Button } from "../../components/ui/Button";
import { InputField, TextAreaField } from "../../components/ui/Field";
import { DataTable } from "../../components/ui/DataTable";

type FormState = {
  titre: string;
  description: string;
  type: QuestionnaireType;
  actif: boolean;
};

type AssignedQuestionForm = {
  questionId: number;
  ordre: number;
  obligatoire: boolean;
};

const initialForm: FormState = {
  titre: "",
  description: "",
  type: "ELIGIBILITE_DONNEUR",
  actif: true
};

export function AdminQuestionnairesPage() {
  const [items, setItems] = useState<Questionnaire[]>([]);
  const [questionBank, setQuestionBank] = useState<Question[]>([]);
  const [selectedQuestions, setSelectedQuestions] = useState<AssignedQuestionForm[]>([]);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [form, setForm] = useState<FormState>(initialForm);
  const [loading, setLoading] = useState(true);
  const [savingMeta, setSavingMeta] = useState(false);
  const [savingAssign, setSavingAssign] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  async function loadAll() {
    const [questionnairesData, questionsData] = await Promise.all([
      questionnaireService.getAll(),
      questionService.getAll()
    ]);

    setItems(questionnairesData);
    setQuestionBank(questionsData);
  }

  useEffect(() => {
    async function init() {
      setLoading(true);
      setError("");

      try {
        const [questionnairesData, questionsData] = await Promise.all([
          questionnaireService.getAll(),
          questionService.getAll()
        ]);

        setItems(questionnairesData);
        setQuestionBank(questionsData);
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
    setSelectedQuestions([]);
    setError("");
    setSuccess("");
  }

  function mapPayload(state: FormState): QuestionnairePayload {
    return {
      titre: state.titre,
      description: state.description || undefined,
      type: state.type,
      actif: state.actif
    };
  }

  async function handleMetaSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSavingMeta(true);
    setError("");
    setSuccess("");

    try {
      const payload = mapPayload(form);

      if (editingId) {
        const updated = await questionnaireService.update(editingId, payload);
        setEditingId(updated.id);
        setSuccess("Questionnaire mis à jour.");
      } else {
        const created = await questionnaireService.create(payload);
        setEditingId(created.id);
        setSuccess("Questionnaire créé. Tu peux maintenant lui affecter des questions.");
      }

      await loadAll();
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSavingMeta(false);
    }
  }

  function handleEdit(item: Questionnaire) {
    setEditingId(item.id);
    setForm({
      titre: item.titre,
      description: item.description || "",
      type: item.type,
      actif: item.actif
    });

    setSelectedQuestions(
      (item.questions || []).map((q) => ({
        questionId: q.questionId,
        ordre: q.ordre,
        obligatoire: q.obligatoire
      }))
    );

    setSuccess("");
    setError("");
  }

  async function handleDelete(id: number) {
    const confirmed = window.confirm("Supprimer ce questionnaire ?");
    if (!confirmed) return;

    try {
      await questionnaireService.remove(id);

      if (editingId === id) {
        resetForm();
      }

      await loadAll();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  function toggleQuestion(questionId: number) {
    setSelectedQuestions((prev) => {
      const exists = prev.find((item) => item.questionId === questionId);

      if (exists) {
        return prev.filter((item) => item.questionId !== questionId);
      }

      return [
        ...prev,
        {
          questionId,
          ordre: prev.length + 1,
          obligatoire: true
        }
      ];
    });
  }

  function updateAssignedQuestion(
    questionId: number,
    patch: Partial<AssignedQuestionForm>
  ) {
    setSelectedQuestions((prev) =>
      prev.map((item) =>
        item.questionId === questionId ? { ...item, ...patch } : item
      )
    );
  }

  async function handleAssignQuestions() {
    if (!editingId) {
      setError("Crée ou sélectionne d’abord un questionnaire.");
      return;
    }

    setSavingAssign(true);
    setError("");
    setSuccess("");

    try {
      await questionnaireService.assignQuestions(editingId, {
        questions: selectedQuestions
          .slice()
          .sort((a, b) => a.ordre - b.ordre)
          .map((item) => ({
            questionId: item.questionId,
            ordre: item.ordre,
            obligatoire: item.obligatoire
          }))
      });

      await loadAll();
      const refreshed = await questionnaireService.getById(editingId);
      handleEdit(refreshed);

      setSuccess("Questions affectées au questionnaire avec succès.");
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSavingAssign(false);
    }
  }

  const selectedCount = useMemo(
    () => selectedQuestions.length,
    [selectedQuestions]
  );

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Questionnaires"
        description="Créer un questionnaire puis y affecter des questions de la banque."
        actions={
          <Button type="button" variant="secondary" onClick={resetForm}>
            Nouveau questionnaire
          </Button>
        }
      />

      {error ? <div className="alert alert--error">{error}</div> : null}
      {success ? <div className="alert alert--success">{success}</div> : null}

      <div className="content-grid">
        <Card
          title={editingId ? "Modifier le questionnaire" : "Créer un questionnaire"}
          subtitle="Enregistre d’abord le questionnaire, puis affecte-lui les questions."
        >
          <form onSubmit={handleMetaSubmit} className="stack">
            <InputField
              label="Titre"
              value={form.titre}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, titre: e.target.value }))
              }
              required
            />

            <TextAreaField
              label="Description"
              rows={3}
              value={form.description}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, description: e.target.value }))
              }
            />

            <div className="grid-two">
              <div>
                <label className="field__label">Type de questionnaire</label>
                <select
                  className="input"
                  value={form.type}
                  onChange={(e) =>
                    setForm((prev) => ({
                      ...prev,
                      type: e.target.value as QuestionnaireType
                    }))
                  }
                >
                  <option value="ELIGIBILITE_DONNEUR">Éligibilité donneur</option>
                  <option value="PRE_DON">Pré-don</option>
                  <option value="POST_DON">Post-don</option>
                </select>
              </div>

              <div style={{ display: "flex", alignItems: "end", paddingBottom: 12 }}>
                <label style={{ display: "flex", gap: 8, alignItems: "center" }}>
                  <input
                    type="checkbox"
                    checked={form.actif}
                    onChange={(e) =>
                      setForm((prev) => ({ ...prev, actif: e.target.checked }))
                    }
                  />
                  <span>Questionnaire actif</span>
                </label>
              </div>
            </div>

            <div className="inline-actions">
              <Button type="submit" disabled={savingMeta}>
                {savingMeta
                  ? "Enregistrement..."
                  : editingId
                  ? "Mettre à jour"
                  : "Créer le questionnaire"}
              </Button>

              {editingId ? (
                <Button type="button" variant="secondary" onClick={resetForm}>
                  Annuler
                </Button>
              ) : null}
            </div>
          </form>
        </Card>

        <Card
          title="Affectation des questions"
          subtitle={
            editingId
              ? `${selectedCount} question(s) sélectionnée(s)`
              : "Sélectionne d’abord un questionnaire dans la liste ou crée-en un."
          }
          actions={
            <Button
              type="button"
              onClick={handleAssignQuestions}
              disabled={!editingId || savingAssign}
            >
              {savingAssign ? "Enregistrement..." : "Enregistrer l’affectation"}
            </Button>
          }
        >
          <div className="stack">
            {questionBank
              .filter((question) => question.actif)
              .map((question) => {
                const selected = selectedQuestions.find(
                  (item) => item.questionId === question.id
                );

                return (
                  <div
                    key={question.id}
                    className="card"
                    style={{ padding: 16, display: "grid", gap: 12 }}
                  >
                    <label style={{ display: "flex", gap: 10, alignItems: "center" }}>
                      <input
                        type="checkbox"
                        checked={!!selected}
                        onChange={() => toggleQuestion(question.id)}
                        disabled={!editingId}
                      />
                      <strong>{question.texte}</strong>
                    </label>

                    <div className="muted small">
                      {question.code ? `${question.code} • ` : ""}
                      {question.typeReponse}
                    </div>

                    {selected ? (
                      <div className="grid-two">
                        <InputField
                          label="Ordre"
                          type="number"
                          value={String(selected.ordre)}
                          onChange={(e) =>
                            updateAssignedQuestion(question.id, {
                              ordre: Number(e.target.value) || 1
                            })
                          }
                        />

                        <div style={{ display: "flex", alignItems: "end", paddingBottom: 12 }}>
                          <label style={{ display: "flex", gap: 8, alignItems: "center" }}>
                            <input
                              type="checkbox"
                              checked={selected.obligatoire}
                              onChange={(e) =>
                                updateAssignedQuestion(question.id, {
                                  obligatoire: e.target.checked
                                })
                              }
                            />
                            <span>Question obligatoire</span>
                          </label>
                        </div>
                      </div>
                    ) : null}
                  </div>
                );
              })}
          </div>
        </Card>
      </div>

      <Card title="Questionnaires enregistrés">
        <DataTable
          data={items}
          columns={[
            { header: "Titre", accessor: "titre" },
            { header: "Type", render: (row) => row.type },
            { header: "Actif", render: (row) => (row.actif ? "Oui" : "Non") },
            { header: "Questions", render: (row) => row.questions?.length ?? 0 },
            {
              header: "Actions",
              render: (row) => (
                <div className="inline-actions">
                  <Button
                    type="button"
                    variant="secondary"
                    onClick={() => handleEdit(row)}
                  >
                    Configurer
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
  );
}