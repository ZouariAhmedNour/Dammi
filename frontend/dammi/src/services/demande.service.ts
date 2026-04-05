import api from "../lib/api";
import type { DemandePayload, DemandeSang } from "../types";

async function getAll(): Promise<DemandeSang[]> {
  const { data } = await api.get("/api/demandes");
  return data;
}

async function getUrgent(): Promise<DemandeSang[]> {
  const { data } = await api.get("/api/demandes/urgentes");
  return data;
}

async function getByUser(userId: number): Promise<DemandeSang[]> {
  const { data } = await api.get(`/api/demandes/user/${userId}`);
  return data;
}

async function create(payload: DemandePayload): Promise<DemandeSang> {
  const { data } = await api.post("/api/demandes", payload);
  return data;
}

async function updateStatus(
  id: number,
  statut: string
): Promise<DemandeSang> {
  const { data } = await api.put(`/api/demandes/${id}/statut`, null, {
    params: { statut }
  });
  return data;
}

async function remove(id: number) {
  await api.delete(`/api/demandes/${id}`);
}

export const demandeService = {
  getAll,
  getUrgent,
  getByUser,
  create,
  updateStatus,
  remove
};