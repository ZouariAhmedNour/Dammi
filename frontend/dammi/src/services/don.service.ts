import api from "../lib/api";
import type { Don } from "../types";

async function getByUser(userId: number): Promise<Don[]> {
  const { data } = await api.get(`/api/dons/user/${userId}`);
  return data;
}

export const donService = {
  getByUser
};