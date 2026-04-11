import api from "../lib/api";

export interface JourDisponible {
  date: string;
  nombreCreneaux: number;
}

export interface CreneauCollecte {
  id: number;
  pointCollecteId: number;
  pointCollecteNom: string;
  typeDonId: number;
  typeDonLabel: string;
  dateCollecte: string;
  heureDebut: string;
  placesTotales: number;
  placesRestantes: number;
  actif: boolean;
}

async function getJoursDisponibles(
  pointCollecteId: number,
  typeDonId: number,
  year: number,
  month: number
): Promise<JourDisponible[]> {
  const { data } = await api.get("/api/creneaux/jours-disponibles", {
    params: { pointCollecteId, typeDonId, year, month }
  });
  return data;
}

async function getCreneauxDuJour(
  pointCollecteId: number,
  typeDonId: number,
  date: string
): Promise<CreneauCollecte[]> {
  const { data } = await api.get("/api/creneaux", {
    params: { pointCollecteId, typeDonId, date }
  });
  return data;
}

async function generatePlanning(pointCollecteId: number, year: number): Promise<void> {
  await api.post("/api/creneaux/generate", null, {
    params: { pointCollecteId, year }
  });
}

export const creneauService = {
  getJoursDisponibles,
  getCreneauxDuJour,
  generatePlanning
};