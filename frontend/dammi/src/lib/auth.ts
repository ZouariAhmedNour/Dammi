import type { AuthUser, Role, SessionData } from "../types";


function decodeBase64Url(value: string) {
  const base64 = value.replace(/-/g, "+").replace(/_/g, "/");
  const padded = base64.padEnd(Math.ceil(base64.length / 4) * 4, "=");
  return atob(padded);
}



export function parseJwtPayload(token: string): Record<string, unknown> {
  try {
    const payload = token.split(".")[1];
    if (!payload) return {};
    return JSON.parse(decodeBase64Url(payload));
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
  response: any,
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
  const responseUser = response?.user ?? response?.currentUser ?? response ?? {};

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
      payload?.prenom ??
      payload?.firstName ??
      "",
    nom:
      responseUser?.nom ??
      responseUser?.lastName ??
      response?.nom ??
      payload?.nom ??
      payload?.lastName ??
      "",
    email:
      responseUser?.email ??
      response?.email ??
      String(payload?.sub ?? fallbackEmail ?? ""),
    phone: responseUser?.phone ?? response?.phone ?? "",
    avatar: responseUser?.avatar ?? response?.avatar ?? "",
    role
  };

    return { token, user };
}