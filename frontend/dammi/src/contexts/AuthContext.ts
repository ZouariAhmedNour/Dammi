import { createContext } from "react";
import type {
  AuthUser,
  LoginPayload,
  RegisterPayload,
  SessionData
} from "../types";

export interface AuthContextValue {
  user: AuthUser | null;
  token: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (payload: LoginPayload) => Promise<SessionData>;
  register: (payload: RegisterPayload) => Promise<SessionData>;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextValue | undefined>(undefined);