import api from "../lib/api";
import type { Questionnaire, QuestionnaireAssignQuestionsPayload, QuestionnairePayload } from "../types";

async function getAll(): Promise<Questionnaire[]> {
  const { data } = await api.get("/api/admin/questionnaires");
  return data;
}

async function getById(id: number): Promise<Questionnaire> {
  const { data } = await api.get(`/api/admin/questionnaires/${id}`);
  return data;
}

async function create(payload: QuestionnairePayload): Promise<Questionnaire> {
  const { data } = await api.post("/api/admin/questionnaires", payload);
  return data;
}

async function update(id: number, payload: QuestionnairePayload): Promise<Questionnaire> {
  const { data } = await api.put(`/api/admin/questionnaires/${id}`, payload);
  return data;
}

async function remove(id: number): Promise<void> {
  await api.delete(`/api/admin/questionnaires/${id}`);
}

async function getAssignedQuestions(id: number) {
  const { data } = await api.get(`/api/admin/questionnaires/${id}/questions`);
  return data;
}

async function assignQuestions(
  id: number,
  payload: QuestionnaireAssignQuestionsPayload
) {
  const { data } = await api.post(`/api/admin/questionnaires/${id}/questions`, payload);
  return data;
}

export const questionnaireService = {
  getAll,
  getById,
  create,
  update,
  remove,
  getAssignedQuestions,
  assignQuestions
};