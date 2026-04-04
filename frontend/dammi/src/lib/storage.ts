import type { SessionData } from "../types";


const SESSION_KEY = "dammi_session";

export function saveSession(session: SessionData) {
  localStorage.setItem(SESSION_KEY, JSON.stringify(session));
}

export function getStoredSession(): SessionData | null {
  const raw = localStorage.getItem(SESSION_KEY);

  if (!raw) return null;

  try {
    return JSON.parse(raw) as SessionData;
  } catch {
    localStorage.removeItem(SESSION_KEY);
    return null;
  }
}

export function clearSession() {
  localStorage.removeItem(SESSION_KEY);
}

