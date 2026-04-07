// import api from "../lib/api";
// import { normalizeSessionFromAuthResponse } from "../lib/auth";
// import type { LoginPayload, RegisterPayload, SessionData } from "../types";

// async function login(payload: LoginPayload): Promise<SessionData> {
//   const { data } = await api.post("/api/auth/login", payload);
//   return normalizeSessionFromAuthResponse(data, payload.email);
// }

// async function register(payload: RegisterPayload): Promise<SessionData> {
//   const { data } = await api.post("/api/auth/register", payload);
//   return normalizeSessionFromAuthResponse(data, payload.email);
// }

// export const authService = {
//   login,
//   register
// };

import api from "../lib/api";
import { normalizeSessionFromAuthResponse } from "../lib/auth";
import type { LoginPayload, RegisterPayload, SessionData } from "../types";
import axios from "axios";

async function login(payload: LoginPayload): Promise<SessionData> {
  try {
    const { data } = await api.post("/api/auth/login", payload);
    return normalizeSessionFromAuthResponse(data, payload.email);
  } catch (error) {
    if (axios.isAxiosError(error)) {
      console.error("LOGIN STATUS:", error.response?.status);
      console.error("LOGIN DATA:", error.response?.data);
    }
    throw error;
  }
}

async function register(payload: RegisterPayload): Promise<SessionData> {
  try {
    console.log("REGISTER PAYLOAD:", payload);
    const { data } = await api.post("/api/auth/register", payload);
    return normalizeSessionFromAuthResponse(data, payload.email);
  } catch (error) {
    if (axios.isAxiosError(error)) {
      console.error("REGISTER STATUS:", error.response?.status);
      console.error("REGISTER DATA:", error.response?.data);
    }
    throw error;
  }
}

export const authService = {
  login,
  register
};