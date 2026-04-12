import api from "../lib/api";
import type { Question, QuestionPayload } from "../types";

async function getAll(): Promise<Question[]> {
  const { data } = await api.get("/api/admin/questions");
  return data;
}

async function getById(id: number): Promise<Question> {
  const { data } = await api.get(`/api/admin/questions/${id}`);
  return data;
}

async function create(payload: QuestionPayload): Promise<Question> {
  const { data } = await api.post("/api/admin/questions", payload);
  return data;
}

async function update(id: number, payload: QuestionPayload): Promise<Question> {
  const { data } = await api.put(`/api/admin/questions/${id}`, payload);
  return data;
}

async function remove(id: number): Promise<void> {
  await api.delete(`/api/admin/questions/${id}`);
}

export const questionService = {
  getAll,
  getById,
  create,
  update,
  remove
};