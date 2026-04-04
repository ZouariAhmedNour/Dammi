import {
  createContext,
  useContext,
  useMemo,
  useState,
  type ReactNode
} from "react";
import type {
  AuthUser,
  LoginPayload,
  RegisterPayload,
  SessionData
} from "../types";
import { clearSession, getStoredSession, saveSession } from "../lib/storage";
import { authService } from "../services/auth.service";

interface AuthContextValue {
  user: AuthUser | null;
  token: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (payload: LoginPayload) => Promise<SessionData>;
  register: (payload: RegisterPayload) => Promise<SessionData>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

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

export function useAuth() {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error("useAuth doit être utilisé dans AuthProvider");
  }

  return context;
}