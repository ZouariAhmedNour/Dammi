import { useEffect, useState } from "react";
import type { Don, DemandeSang, PointCollecte } from "../../types";
import { pointCollecteService } from "../../services/pointCollecte.service";
import { demandeService } from "../../services/demande.service";
import { donService } from "../../services/don.service";
import { formatDate, getApiErrorMessage, getBloodTypeLabel, getPointCollecteName } from "../../lib/helpers";
import { Loader } from "../../components/ui/Loader";
import { PageHeader } from "../../components/ui/PageHeader";
import { StatCard } from "../../components/ui/StatCard";
import { DataTable } from "../../components/ui/DataTable";
import { Card } from "../../components/ui/Card";
import { Badge } from "../../components/ui/Badge";
import { useAuth } from "../../contexts/useAuth";

export function UserHomePage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [points, setPoints] = useState<PointCollecte[]>([]);
  const [demandes, setDemandes] = useState<DemandeSang[]>([]);
  const [dons, setDons] = useState<Don[]>([]);

  useEffect(() => {
    async function load() {
      setLoading(true);
      setError("");

      try {
        const pointsPromise = pointCollecteService.getAll();

        const demandesPromise =
          user?.id != null
            ? demandeService.getByUser(user.id)
            : Promise.resolve([]);

        const donsPromise =
          user?.id != null ? donService.getByUser(user.id) : Promise.resolve([]);

        const [pointsData, demandesData, donsData] = await Promise.all([
          pointsPromise,
          demandesPromise,
          donsPromise
        ]);

        setPoints(pointsData);
        setDemandes(demandesData);
        setDons(donsData);
      } catch (err) {
        setError(getApiErrorMessage(err));
      } finally {
        setLoading(false);
      }
    }

    load();
  }, [user?.id]);

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Mon espace"
        description="Consultez vos activités et les points de collecte disponibles."
      />

      {error ? <div className="alert alert--error">{error}</div> : null}

      {!user?.id ? (
        <div className="alert alert--warning">
          Le token ne retourne pas d'identifiant utilisateur. Les listes
          personnelles ne peuvent pas être chargées tant que l'id n'est pas
          présent dans la réponse d'authentification ou dans le JWT.
        </div>
      ) : null}

      <div className="stats-grid">
        <StatCard label="Mes dons" value={dons.length} />
        <StatCard label="Mes demandes" value={demandes.length} />
        <StatCard label="Points disponibles" value={points.length} />
      </div>

      <div className="content-grid">
        <Card title="Mes dons">
          <DataTable
            data={dons.slice(0, 5)}
            columns={[
              {
                header: "Date don",
                render: (row) => formatDate(row.dateDon)
              },
              {
                header: "Type sanguin",
                render: (row) => getBloodTypeLabel(row)
              },
              {
                header: "Centre",
                render: (row) => getPointCollecteName(row)
              },
              {
                header: "Statut",
                render: (row) => <Badge variant="info">{row.status}</Badge>
              }
            ]}
          />
        </Card>

        <Card title="Mes demandes">
          <DataTable
            data={demandes.slice(0, 5)}
            columns={[
              {
                header: "Contact",
                accessor: "contactNom"
              },
              {
                header: "Type",
                render: (row) => getBloodTypeLabel(row)
              },
              {
                header: "Quantité",
                render: (row) => row.quantite
              },
              {
                header: "Statut",
                render: (row) => <Badge variant="info">{row.statut}</Badge>
              }
            ]}
          />
        </Card>
      </div>

      <Card title="Points de collecte publics">
        <DataTable
          data={points}
          columns={[
            { header: "Nom", accessor: "nom" },
            { header: "Ville", accessor: "ville" },
            { header: "Adresse", accessor: "adresse" },
            { header: "Téléphone", render: (row) => row.telephone || "-" }
          ]}
        />
      </Card>
    </div>
  );
}