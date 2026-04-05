import { useMemo, useState, type ReactNode } from "react";
import type { SessionData } from "react-router-dom";
import { clearSession, getStoredSession, saveSession } from "../lib/storage";
import { authService } from "../services/auth.service";
import type { LoginPayload, RegisterPayload } from "../types";
import { AuthContext, type AuthContextValue } from "./AuthContext";

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<SessionData | null>(getStoredSession());
  const [loading, setLoading] = useState(false);

  const login = async (payload: LoginPayload) => {
    setLoading(true);
    try {
      const nextSession = await authService.login(payload);
      saveSession(nextSession);
      setSession(nextSession);
      return nextSession;
    } finally {
      setLoading(false);
    }
  };

  const register = async (payload: RegisterPayload) => {
    setLoading(true);
    try {
      const nextSession = await authService.register(payload);
      saveSession(nextSession);
      setSession(nextSession);
      return nextSession;
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    clearSession();
    setSession(null);
  };

  const value = useMemo<AuthContextValue>(
    () => ({
      user: session?.user ?? null,
      token: session?.token ?? null,
      isAuthenticated: Boolean(session?.token),
      loading,
      login,
      register,
      logout
    }),
    [session, loading]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}