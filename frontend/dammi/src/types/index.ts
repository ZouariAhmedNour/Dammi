export type Role = "ADMIN" | "AGENT" | "USER";

export interface AuthUser {
  id?: number;
  prenom?: string;
  nom?: string;
  email: string;
  phone?: string;
  avatar?: string;
  role: Role;
}

export interface SessionData {
  token: string;
  user: AuthUser;
}

export interface LoginPayload {
  email: string;
  password: string;
}

export interface RegisterPayload {
  prenom: string;
  nom: string;
  email: string;
  phone?: string;
  password: string;
}

export interface User extends AuthUser {
  lastDonation?: string | null;
  eligibilityStatus?: string | null;
  statutPertinent?: boolean | null;
  createdAt?: string;
  updatedAt?: string;
}

export interface TypeSanguin {
  id: number;
  label?: string;
  aboGroup?: string;
}

export interface TypeSanguinPayload {
  label: string;
  aboGroup: string;
}

export interface TypeDon {
  id: number;
  label: string;
}

export interface TypeDonPayload {
  label: string;
}

export interface PointCollecte {
  id: number;
  nom: string;
  gouvernorat: string;
  delegation: string;
  codePostal: string;
  adressePostale: string;
  capacite: number;
  telephone?: string;
  latitude: number;
  longitude: number;
  description?: string;
  typesDon?: TypeDon[];
}

export interface PointCollectePayload {
  nom: string;
  gouvernorat: string;
  delegation: string;
  codePostal: string;
  adressePostale: string;
  capacite: number;
  telephone?: string;
  latitude: number;
  longitude: number;
  description?: string;
  typeDonIds: number[];
}

export interface GouvernoratOption {
  nom: string;
  nomAr?: string;
  latitude: number;
  longitude: number;
}

export interface DelegationOption {
  nom: string;
  nomAr?: string;
  codePostal: string;
  latitude: number;
  longitude: number;
}

export interface StockSanguin {
  id: number;
  quantiteDisponible: number;
  seuilMinimum: number;
  typeSanguin?: TypeSanguin;
  pointCollecte?: PointCollecte;
  typeSanguinLabel?: string;
  pointCollecteNom?: string;
  typeSanguinId?: number;
  pointCollecteId?: number;
}

export interface StockPayload {
  quantiteDisponible: number;
  seuilMinimum: number;
  typeSanguinId: number;
  pointCollecteId?: number;
}

export interface Don {
  id: number;
  dateDon: string;
  status: string;
  createdAt?: string;
  user?: User;
  typeDon?: TypeDon;
  pointCollecte?: PointCollecte;
  typeSanguin?: TypeSanguin;
  typeSanguinLabel?: string;
  pointCollecteNom?: string;
}

export interface DemandeSang {
  id: number;
  quantite: number;
  statut: string;
  dateCreation?: string;
  urgence: boolean;
  contactNom: string;
  raisonDemande?: string;
  notesComplementaires?: string;
  user?: User;
  typeSanguin?: TypeSanguin;
  typeSanguinLabel?: string;
}

export interface DemandePayload {
  quantite: number;
  urgence: boolean;
  contactNom: string;
  raisonDemande?: string;
  notesComplementaires?: string;
  typeSanguinId?: number;
  userId?: number;
}