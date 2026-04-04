import api from "../lib/api";
import type { PointCollecte, PointCollectePayload } from "../types";

async function getAll(): Promise<PointCollecte[]> {
  const { data } = await api.get("/api/points-collecte");
  return data;
}

async function getByVille(ville: string): Promise<PointCollecte[]> {
  const { data } = await api.get(`/api/points-collecte/ville/${ville}`);
  return data;
}

async function create(payload: PointCollectePayload): Promise<PointCollecte> {
  const { data } = await api.post("/api/points-collecte", payload);
  return data;
}

async function update(
  id: number,
  payload: PointCollectePayload
): Promise<PointCollecte> {
  const { data } = await api.put(`/api/points-collecte/${id}`, payload);
  return data;
}

async function remove(id: number) {
  await api.delete(`/api/points-collecte/${id}`);
}

export const pointCollecteService = {
  getAll,
  getByVille,
  create,
  update,
  remove
};