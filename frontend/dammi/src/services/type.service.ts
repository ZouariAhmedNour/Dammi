import api from "../lib/api";
import type { TypeDon, TypeSanguin } from "../types";

async function getBloodTypes(): Promise<TypeSanguin[]> {
  const { data } = await api.get("/api/types-sanguin");
  return data;
}

async function getDonationTypes(): Promise<TypeDon[]> {
  const { data } = await api.get("/api/types-don");
  return data;
}

export const typeService = {
  getBloodTypes,
  getDonationTypes
};