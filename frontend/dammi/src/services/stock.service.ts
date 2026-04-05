import api from "../lib/api";
import type { StockPayload, StockSanguin } from "../types";

async function getAll(): Promise<StockSanguin[]> {
  const { data } = await api.get("/api/stocks");
  return data;
}

async function getAlerts(): Promise<StockSanguin[]> {
  const { data } = await api.get("/api/stocks/alerte");
  return data;
}

async function create(payload: StockPayload): Promise<StockSanguin> {
  const { data } = await api.post("/api/stocks", payload);
  return data;
}

async function updateQuantity(
  id: number,
  quantite: number
): Promise<StockSanguin> {
  const { data } = await api.put(`/api/stocks/${id}/quantite`, null, {
    params: { quantite }
  });
  return data;
}

async function remove(id: number) {
  await api.delete(`/api/stocks/${id}`);
}

export const stockService = {
  getAll,
  getAlerts,
  create,
  updateQuantity,
  remove
};