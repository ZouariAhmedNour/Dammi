import api from "../lib/api";
import type { DelegationOption, GouvernoratOption } from "../types";

async function getGouvernorats(): Promise<GouvernoratOption[]> {
  const { data } = await api.get("/api/localisation/gouvernorats");
  return data;
}

async function getDelegations(gouvernorat: string): Promise<DelegationOption[]> {
  const { data } = await api.get("/api/localisation/delegations", {
    params: { gouvernorat }
  });
  return data;
}

export const localisationService = {
  getGouvernorats,
  getDelegations
};