import { useEffect, useState } from "react";
import type { DemandeSang, StockSanguin } from "../../types";
import { stockService } from "../../services/stock.service";
import { demandeService } from "../../services/demande.service";
import { formatDateTime, getApiErrorMessage, getBloodTypeLabel, isStockAlert } from "../../lib/helpers";
import { Loader } from "../../components/ui/Loader";
import { Badge } from "../../components/ui/Badge";
import { PageHeader } from "../../components/ui/PageHeader";
import { StatCard } from "../../components/ui/StatCard";
import { DataTable } from "../../components/ui/DataTable";
import { Card } from "../../components/ui/Card";

export function AgentDashboardPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [stocks, setStocks] = useState<StockSanguin[]>([]);
  const [alerts, setAlerts] = useState<StockSanguin[]>([]);
  const [urgentDemandes, setUrgentDemandes] = useState<DemandeSang[]>([]);

  useEffect(() => {
    async function load() {
      setLoading(true);
      setError("");

      try {
        const [stocksData, alertsData, urgentes] = await Promise.all([
          stockService.getAll(),
          stockService.getAlerts(),
          demandeService.getUrgent()
        ]);

        setStocks(stocksData);
        setAlerts(alertsData);
        setUrgentDemandes(urgentes);
      } catch (err) {
        setError(getApiErrorMessage(err));
      } finally {
        setLoading(false);
      }
    }

    load();
  }, []);

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Dashboard agent"
        description="Surveillez le stock, les alertes et les demandes urgentes."
      />

      {error ? <div className="alert alert--error">{error}</div> : null}

      <div className="stats-grid">
        <StatCard label="Stocks total" value={stocks.length} />
        <StatCard
          label="Alertes stock"
          value={alerts.length}
          tone={alerts.length > 0 ? "danger" : "default"}
        />
        <StatCard
          label="Demandes urgentes"
          value={urgentDemandes.length}
          tone={urgentDemandes.length > 0 ? "danger" : "default"}
        />
      </div>

      <div className="content-grid">
        <Card title="Stocks critiques">
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

        <Card title="Demandes urgentes">
          <DataTable
            data={urgentDemandes.slice(0, 6)}
            columns={[
              {
                header: "Contact",
                accessor: "contactNom"
              },
              {
                header: "Type sanguin",
                render: (row) => getBloodTypeLabel(row)
              },
              {
                header: "Quantité",
                render: (row) => row.quantite
              },
              {
                header: "Date",
                render: (row) => formatDateTime(row.dateCreation)
              }
            ]}
          />
        </Card>
      </div>
    </div>
  );
}