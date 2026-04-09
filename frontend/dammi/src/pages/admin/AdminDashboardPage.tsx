import { useEffect, useState } from "react";
import { Badge } from "../../components/ui/Badge";
import { Card } from "../../components/ui/Card";
import { DataTable } from "../../components/ui/DataTable";
import { Loader } from "../../components/ui/Loader";
import { PageHeader } from "../../components/ui/PageHeader";
import { StatCard } from "../../components/ui/StatCard";
import {
  getApiErrorMessage,
  getBloodTypeLabel,
  isStockAlert
} from "../../lib/helpers";
import { demandeService } from "../../services/demande.service";
import { pointCollecteService } from "../../services/pointCollecte.service";
import { stockService } from "../../services/stock.service";
import { typeService } from "../../services/type.service";
import { userService } from "../../services/user.service";
import type { PointCollecte, StockSanguin, TypeDon, TypeSanguin, User } from "../../types";

export function AdminDashboardPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [users, setUsers] = useState<User[]>([]);
  const [points, setPoints] = useState<PointCollecte[]>([]);
  const [alerts, setAlerts] = useState<StockSanguin[]>([]);
  const [urgentCount, setUrgentCount] = useState(0);
  const [bloodTypes, setBloodTypes] = useState<TypeSanguin[]>([]);
  const [donationTypes, setDonationTypes] = useState<TypeDon[]>([]);

  useEffect(() => {
    async function load() {
      setLoading(true);
      setError("");

      try {
        const [
          usersData,
          pointsData,
          alertStocks,
          urgentes,
          bloodTypesData,
          donationTypesData
        ] = await Promise.all([
          userService.getAll(),
          pointCollecteService.getAll(),
          stockService.getAlerts(),
          demandeService.getUrgent(),
          typeService.getBloodTypes(),
          typeService.getDonationTypes()
        ]);

        setUsers(usersData);
        setPoints(pointsData);
        setAlerts(alertStocks);
        setUrgentCount(urgentes.length);
        setBloodTypes(bloodTypesData);
        setDonationTypes(donationTypesData);
      } catch (err) {
        setError(getApiErrorMessage(err));
      } finally {
        setLoading(false);
      }
    }

    void load();
  }, []);

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Dashboard admin"
        description="Vue d’ensemble des utilisateurs, points de collecte, types et alertes de stock."
      />

      {error ? <div className="alert alert--error">{error}</div> : null}

      <div className="stats-grid">
        <StatCard label="Utilisateurs" value={users.length} />
        <StatCard
          label="Agents"
          value={users.filter((user) => user.role === "AGENT").length}
        />
        <StatCard label="Points de collecte" value={points.length} />
        <StatCard label="Types sanguins" value={bloodTypes.length} />
        <StatCard label="Types de don" value={donationTypes.length} />
        <StatCard
          label="Demandes urgentes"
          value={urgentCount}
          tone={urgentCount > 0 ? "danger" : "default"}
        />
      </div>

      <div className="content-grid">
        <Card
          title="Derniers points de collecte"
          subtitle="Les centres récemment ajoutés ou synchronisés."
        >
          <DataTable
            data={points.slice(0, 6)}
            columns={[
              { header: "Nom", accessor: "nom" },
              { header: "Gouvernorat", accessor: "gouvernorat" },
              { header: "Délégation", accessor: "delegation" },
              { header: "Adresse", accessor: "adressePostale" },
              { header: "Capacité", accessor: "capacite" }
            ]}
          />
        </Card>

        <Card
          title="Stocks à surveiller"
          subtitle="Stocks sous le seuil minimum."
        >
          <DataTable
            data={alerts.slice(0, 6)}
            columns={[
              {
                header: "Groupe",
                render: (row) => getBloodTypeLabel(row)
              },
              {
                header: "Disponible",
                render: (row) => row.quantiteDisponible
              },
              {
                header: "Seuil",
                render: (row) => row.seuilMinimum
              },
              {
                header: "Statut",
                render: (row) => (
                  <Badge variant={isStockAlert(row) ? "danger" : "success"}>
                    {isStockAlert(row) ? "Critique" : "Stable"}
                  </Badge>
                )
              }
            ]}
          />
        </Card>
      </div>
    </div>
  );
}