import { useEffect, useMemo, useState } from "react";
import type { Role, User } from "../../types";
import { userService } from "../../services/user.service";
import { getApiErrorMessage, getUserDisplayName } from "../../lib/helpers";
import { Loader } from "../../components/ui/Loader";
import { PageHeader } from "../../components/ui/PageHeader";
import { Card } from "../../components/ui/Card";
import { InputField, SelectField } from "../../components/ui/Field";
import { DataTable } from "../../components/ui/DataTable";
import { Badge } from "../../components/ui/Badge";
import { Button } from "../../components/ui/Button";

const roleOptions = [
  { label: "Tous les rôles", value: "ALL" },
  { label: "ADMIN", value: "ADMIN" },
  { label: "AGENT", value: "AGENT" },
  { label: "USER", value: "USER" }
];

export function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [role, setRole] = useState<"ALL" | Role>("ALL");
  const [error, setError] = useState("");

  async function load() {
    setLoading(true);
    setError("");

    try {
      const data = await userService.getAll();
      setUsers(data);
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function handleDelete(id: number) {
    const confirmed = window.confirm("Supprimer cet utilisateur ?");
    if (!confirmed) return;

    try {
      await userService.remove(id);
      await load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  const filteredUsers = useMemo(() => {
    return users.filter((user) => {
      const matchesQuery =
        query.trim() === "" ||
        getUserDisplayName(user).toLowerCase().includes(query.toLowerCase()) ||
        user.email?.toLowerCase().includes(query.toLowerCase());

      const matchesRole = role === "ALL" || user.role === role;

      return matchesQuery && matchesRole;
    });
  }, [users, query, role]);

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Utilisateurs"
        description="Gestion simple des comptes admin, agent et donneur."
      />

      {error ? <div className="alert alert--error">{error}</div> : null}

      <Card>
        <div className="toolbar">
          <InputField
            label="Recherche"
            placeholder="Nom ou email..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
          />

          <SelectField
            label="Rôle"
            value={role}
            onChange={(e) => setRole(e.target.value as "ALL" | Role)}
            options={roleOptions}
          />
        </div>
      </Card>

      <Card title="Liste des utilisateurs">
        <DataTable
          data={filteredUsers}
          columns={[
            {
              header: "Identité",
              render: (user) => (
                <div>
                  <strong>{getUserDisplayName(user)}</strong>
                  <div className="muted small">{user.email}</div>
                </div>
              )
            },
            {
              header: "Téléphone",
              render: (user) => user.phone || "-"
            },
            {
              header: "Rôle",
              render: (user) => (
                <Badge
                  variant={
                    user.role === "ADMIN"
                      ? "danger"
                      : user.role === "AGENT"
                      ? "warning"
                      : "info"
                  }
                >
                  {user.role}
                </Badge>
              )
            },
            {
              header: "Éligibilité",
              render: (user) => user.eligibilityStatus || "-"
            },
            {
              header: "Actions",
              render: (user) => (
                <div className="inline-actions">
                  <Button
                    variant="danger"
                    onClick={() => user.id && handleDelete(user.id)}
                  >
                    Supprimer
                  </Button>
                </div>
              )
            }
          ]}
        />
      </Card>
    </div>
  );
}