import api from "../lib/api";
import type { User } from "../types";

async function getAll(): Promise<User[]> {
  const { data } = await api.get("/api/users");
  return data;
}

async function getById(id: number): Promise<User> {
  const { data } = await api.get(`/api/users/${id}`);
  return data;
}

async function remove(id: number) {
  await api.delete(`/api/users/${id}`);
}

export const userService = {
  getAll,
  getById,
  remove
};