import type { AuthUser, Role, SessionData } from "../types";

type JwtPayload = {
  sub?: string;
  role?: unknown;
  roles?: unknown;
  authorities?: unknown;
  userId?: unknown;
  id?: unknown;
  prenom?: unknown;
  nom?: unknown;
  firstName?: unknown;
  lastName?: unknown;
};

type AuthLikeResponse = {
  token?: string;
  jwt?: string;
  accessToken?: string;
  access_token?: string;
  role?: unknown;
  authorities?: unknown;
  email?: string;
  prenom?: string;
  nom?: string;
  phone?: string;
  avatar?: string;
  userId?: unknown;
  user?: {
    id?: unknown;
    prenom?: string;
    nom?: string;
    firstName?: string;
    lastName?: string;
    email?: string;
    phone?: string;
    avatar?: string;
    role?: unknown;
    authorities?: unknown;
  };
  currentUser?: {
    id?: unknown;
    prenom?: string;
    nom?: string;
    firstName?: string;
    lastName?: string;
    email?: string;
    phone?: string;
    avatar?: string;
    role?: unknown;
    authorities?: unknown;
  };
};

function decodeBase64Url(value: string) {
  const base64 = value.replace(/-/g, "+").replace(/_/g, "/");
  const padded = base64.padEnd(Math.ceil(base64.length / 4) * 4, "=");
  return atob(padded);
}

export function parseJwtPayload(token: string): JwtPayload {
  try {
    const payload = token.split(".")[1];
    if (!payload) return {};
    return JSON.parse(decodeBase64Url(payload)) as JwtPayload;
  } catch {
    return {};
  }
}

export function normalizeRole(value: unknown): Role {
  if (Array.isArray(value)) {
    return normalizeRole(value[0]);
  }

  if (value && typeof value === "object" && "authority" in value) {
    return normalizeRole((value as { authority?: unknown }).authority);
  }

  const raw = String(value ?? "").toUpperCase().replace("ROLE_", "");

  if (raw.includes("ADMIN")) return "ADMIN";
  if (raw.includes("AGENT")) return "AGENT";
  return "USER";
}

export function resolveHomeRoute(role?: Role) {
  if (role === "ADMIN") return "/admin";
  if (role === "AGENT") return "/agent";
  return "/user";
}

export function normalizeSessionFromAuthResponse(
  response: AuthLikeResponse,
  fallbackEmail = ""
): SessionData {
  const token =
    response?.token ??
    response?.jwt ??
    response?.accessToken ??
    response?.access_token ??
    "";

  if (!token) {
    throw new Error("Token absent dans la réponse d'authentification.");
  }

  const payload = parseJwtPayload(token);
  const responseUser = response?.user ?? response?.currentUser ?? {};

  const authorities =
    responseUser?.authorities ??
    response?.authorities ??
    payload?.authorities ??
    payload?.roles;

  const role = normalizeRole(
    responseUser?.role ?? response?.role ?? payload?.role ?? authorities
  );

  const user: AuthUser = {
    id: Number(
      responseUser?.id ??
        response?.userId ??
        payload?.userId ??
        payload?.id ??
        0
    ) || undefined,
    prenom:
      responseUser?.prenom ??
      responseUser?.firstName ??
      response?.prenom ??
      (typeof payload?.prenom === "string" ? payload.prenom : undefined) ??
      (typeof payload?.firstName === "string" ? payload.firstName : undefined) ??
      "",
    nom:
      responseUser?.nom ??
      responseUser?.lastName ??
      response?.nom ??
      (typeof payload?.nom === "string" ? payload.nom : undefined) ??
      (typeof payload?.lastName === "string" ? payload.lastName : undefined) ??
      "",
    email:
      responseUser?.email ??
      response?.email ??
      (typeof payload?.sub === "string" ? payload.sub : fallbackEmail),
    phone: responseUser?.phone ?? response?.phone ?? "",
    avatar: responseUser?.avatar ?? response?.avatar ?? "",
    role
  };

  return { token, user };
}