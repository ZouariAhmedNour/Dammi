import api from "../lib/api";
import { normalizeSessionFromAuthResponse } from "../lib/auth";
import type { LoginPayload, RegisterPayload, SessionData } from "../types";

async function login(payload: LoginPayload): Promise<SessionData> {
  const { data } = await api.post("/api/auth/login", payload);
  return normalizeSessionFromAuthResponse(data, payload.email);
}

async function register(payload: RegisterPayload): Promise<SessionData> {
  const { data } = await api.post("/api/auth/register", payload);
  return normalizeSessionFromAuthResponse(data, payload.email);
}

export const authService = {
  login,
  register
};