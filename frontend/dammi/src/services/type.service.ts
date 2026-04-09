import api from "../lib/api";
import type {
  TypeDon,
  TypeDonPayload,
  TypeSanguin,
  TypeSanguinPayload
} from "../types";

// ===== TYPES SANGUINS =====
async function getBloodTypes(): Promise<TypeSanguin[]> {
  const { data } = await api.get("/api/types-sanguin");
  return data;
}

async function getBloodTypeById(id: number): Promise<TypeSanguin> {
  const { data } = await api.get(`/api/types-sanguin/${id}`);
  return data;
}

async function createBloodType(payload: TypeSanguinPayload): Promise<TypeSanguin> {
  const { data } = await api.post("/api/types-sanguin", payload);
  return data;
}

async function updateBloodType(
  id: number,
  payload: TypeSanguinPayload
): Promise<TypeSanguin> {
  const { data } = await api.put(`/api/types-sanguin/${id}`, payload);
  return data;
}

async function deleteBloodType(id: number): Promise<void> {
  await api.delete(`/api/types-sanguin/${id}`);
}

// ===== TYPES DE DON =====
async function getDonationTypes(): Promise<TypeDon[]> {
  const { data } = await api.get("/api/types-don");
  return data;
}

async function getDonationTypeById(id: number): Promise<TypeDon> {
  const { data } = await api.get(`/api/types-don/${id}`);
  return data;
}

async function createDonationType(payload: TypeDonPayload): Promise<TypeDon> {
  const { data } = await api.post("/api/types-don", payload);
  return data;
}

async function updateDonationType(
  id: number,
  payload: TypeDonPayload
): Promise<TypeDon> {
  const { data } = await api.put(`/api/types-don/${id}`, payload);
  return data;
}

async function deleteDonationType(id: number): Promise<void> {
  await api.delete(`/api/types-don/${id}`);
}

export const typeService = {
  getBloodTypes,
  getBloodTypeById,
  createBloodType,
  updateBloodType,
  deleteBloodType,

  getDonationTypes,
  getDonationTypeById,
  createDonationType,
  updateDonationType,
  deleteDonationType
};