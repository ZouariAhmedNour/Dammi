import { Navigate, Outlet } from "react-router-dom";
import { resolveHomeRoute } from "../../lib/auth";
import type { Role } from "../../types";
import { Loader } from "../ui/Loader";
import { useAuth } from "../../contexts/useAuth";

export function ProtectedRoute({
  allowedRoles
}: {
  allowedRoles: Role[];
}) {
  const { user } = useAuth();

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (!allowedRoles.includes(user.role)) {
    return <Navigate to={resolveHomeRoute(user.role)} replace />;
  }

  return <Outlet />;
}

export function GuestOnlyRoute() {
  const { user, loading } = useAuth();

  if (loading) return <Loader fullPage />;

  if (user) {
    return <Navigate to={resolveHomeRoute(user.role)} replace />;
  }

  return <Outlet />;
}

export function HomeRedirect() {
  const { user, loading } = useAuth();

  if (loading) return <Loader fullPage />;

  if (!user) return <Navigate to="/login" replace />;

  return <Navigate to={resolveHomeRoute(user.role)} replace />;
}