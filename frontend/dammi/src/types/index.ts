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

export type QuestionTypeReponse =
  | "YES_NO"
  | "SINGLE_CHOICE"
  | "MULTIPLE_CHOICE"
  | "TEXT"
  | "NUMBER"
  | "DATE";

export type QuestionnaireType =
  | "ELIGIBILITE_DONNEUR"
  | "PRE_DON"
  | "POST_DON";

export type QuestionnaireResultat =
  | "EN_ATTENTE"
  | "ELIGIBLE"
  | "NON_ELIGIBLE";

export interface QuestionOption {
  id: number;
  label: string;
  value: string;
  ordre: number;
  bloquante: boolean;
  active: boolean;
}

export interface Question {
  id: number;
  texte: string;
  typeReponse: QuestionTypeReponse;
  aide?: string;
  actif: boolean;
  options: QuestionOption[];
}

export interface QuestionPayload {
  texte: string;
  typeReponse: QuestionTypeReponse;
  aide?: string;
  actif: boolean;
  options?: {
    label: string;
    value: string;
    ordre?: number;
    bloquante?: boolean;
    active?: boolean;
  }[];
}

export interface QuestionnaireQuestionItem {
  id: number;
  questionId: number;
  ordre: number;
  obligatoire: boolean;
  question: Question;
}

export interface Questionnaire {
  id: number;
  titre: string;
  description?: string;
  type: QuestionnaireType;
  actif: boolean;
  createdAt?: string;
  questions: QuestionnaireQuestionItem[];
}

export interface QuestionnairePayload {
  titre: string;
  description?: string;
  type: QuestionnaireType;
  actif: boolean;
}

export interface QuestionnaireAssignQuestionsPayload {
  questions: {
    questionId: number;
    ordre: number;
    obligatoire?: boolean;
  }[];
}