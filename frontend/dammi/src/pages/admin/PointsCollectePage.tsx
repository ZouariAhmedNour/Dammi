import { useEffect, useMemo, useState } from "react";
import * as L from "leaflet";
import "leaflet/dist/leaflet.css";
import markerIcon2x from "leaflet/dist/images/marker-icon-2x.png";
import markerIcon from "leaflet/dist/images/marker-icon.png";
import markerShadow from "leaflet/dist/images/marker-shadow.png";

import {
  MapContainer,
  Marker,
  TileLayer,
  useMap,
  useMapEvents
} from "react-leaflet";

import type {
  DelegationOption,
  GouvernoratOption,
  PointCollecte,
  PointCollectePayload,
  TypeDon
} from "../../types";

import { pointCollecteService } from "../../services/pointCollecte.service";
import { localisationService } from "../../services/localisation.service";
import { getApiErrorMessage } from "../../lib/helpers";
import { Loader } from "../../components/ui/Loader";
import { PageHeader } from "../../components/ui/PageHeader";
import { Card } from "../../components/ui/Card";
import { InputField, TextAreaField } from "../../components/ui/Field";
import { Button } from "../../components/ui/Button";
import { DataTable } from "../../components/ui/DataTable";
import { creneauService } from "../../services/creneau.service";
import { typeService } from "../../services/type.service";

L.Icon.Default.mergeOptions({
  iconRetinaUrl: markerIcon2x,
  iconUrl: markerIcon,
  shadowUrl: markerShadow
});


type FormState = {
  nom: string;
  gouvernorat: string;
  delegation: string;
  codePostal: string;
  adressePostale: string;
  capacite: string;
  telephone: string;
  latitude: string;
  longitude: string;
  description: string;
  typeDonIds: number[];
  autoGeneratePlanning: boolean;
  planningYear: string;
};

const TUNISIA_CENTER: [number, number] = [34.0, 9.0];

const initialForm: FormState = {
  nom: "",
 gouvernorat: "",
  delegation: "",
  codePostal: "",
  adressePostale: "",
  capacite: "10",
  telephone: "",
 latitude: String(TUNISIA_CENTER[0]),
  longitude: String(TUNISIA_CENTER[1]),
  description: "",
  typeDonIds: [],
  autoGeneratePlanning: false,
  planningYear: String(new Date().getFullYear())
};

function ChangeMapView({ center }: { center: [number, number] }) {
  const map = useMap();

  useEffect(() => {
    map.setView(center, 10);
  }, [center, map]);

  return null;
}

function LocationPicker({
  position,
  onChange
}: {
  position: [number, number];
  onChange: (lat: number, lng: number) => void;
}) {
  useMapEvents({
    click(e) {
      onChange(e.latlng.lat, e.latlng.lng);
    }
  });

  return (
    <Marker
      position={position}
      icon={pointCollecteIcon}
      draggable={true}
      eventHandlers={{
        dragend: (e) => {
          const marker = e.target as L.Marker;
          const { lat, lng } = marker.getLatLng();
          onChange(lat, lng);
        }
      }}
    />
  );
}

export function PointsCollectePage() {
  const [points, setPoints] = useState<PointCollecte[]>([]);
  const [gouvernorats, setGouvernorats] = useState<GouvernoratOption[]>([]);
  const [delegations, setDelegations] = useState<DelegationOption[]>([]);
  const [donationTypes, setDonationTypes] = useState<TypeDon[]>([]);
  const [form, setForm] = useState<FormState>(initialForm);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [mapCenter, setMapCenter] = useState<[number, number]>(TUNISIA_CENTER);

  async function loadPoints() {
    const data = await pointCollecteService.getAll();
    setPoints(data);
  }
  
  useEffect(() => {
  async function init() {
    setLoading(true);
    setError("");

    try {
      const [pointsData, gouvernoratsData, donationTypesData] =
        await Promise.all([
          pointCollecteService.getAll(),
          localisationService.getGouvernorats(),
          typeService.getDonationTypes()
        ]);

      setPoints(pointsData);
      setGouvernorats(gouvernoratsData);
      setDonationTypes(donationTypesData);
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setLoading(false);
    }
  }
  init();
}, []);

   function resetForm() {
    setForm(initialForm);
    setDelegations([]);
    setEditingId(null);
    setMapCenter(TUNISIA_CENTER);
    setError("");
    setSuccess("");
  }

  function mapFormToPayload(state: FormState): PointCollectePayload {
    return {
      nom: state.nom,
      gouvernorat: state.gouvernorat,
      delegation: state.delegation,
      codePostal: state.codePostal,
      adressePostale: state.adressePostale,
      capacite: Number(state.capacite),
      telephone: state.telephone || undefined,
      latitude: Number(state.latitude),
      longitude: Number(state.longitude),
      description: state.description || undefined,
      typeDonIds: state.typeDonIds    
    };
  }

  function setPosition(lat: number, lng: number) {
    setForm((prev) => ({
      ...prev,
      latitude: String(lat),
      longitude: String(lng)
    }));
    setMapCenter([lat, lng]);
  }

  function handleTypeDonToggle(typeId: number) {
    setForm((prev) => {
      const exists = prev.typeDonIds.includes(typeId);

      return {
        ...prev,
        typeDonIds: exists
          ? prev.typeDonIds.filter((id) => id !== typeId)
          : [...prev.typeDonIds, typeId]
      };
    });
  }


  async function handleGouvernoratChange(value: string) {
    setError("");

    const selected = gouvernorats.find((g) => g.nom === value);

    setForm((prev) => ({
      ...prev,
      gouvernorat: value,
      delegation: "",
      codePostal: "",
      latitude: selected ? String(selected.latitude) : prev.latitude,
      longitude: selected ? String(selected.longitude) : prev.longitude
    }));

    if (selected) {
      setMapCenter([selected.latitude, selected.longitude]);
    }

    try {
     const data = value
  ? await localisationService.getDelegations(value)
  : [];
setDelegations(dedupeDelegations(data));
    } catch (err) {
      setDelegations([]);
      setError(getApiErrorMessage(err));
    }
  }

  function handleDelegationChange(value: string) {
    const selected = delegations.find((d) => d.nom === value);

    setForm((prev) => ({
      ...prev,
      delegation: value,
      codePostal: selected?.codePostal || prev.codePostal,
      latitude: selected ? String(selected.latitude) : prev.latitude,
      longitude: selected ? String(selected.longitude) : prev.longitude
    }));

    if (selected?.latitude != null && selected?.longitude != null) {
      setMapCenter([selected.latitude, selected.longitude]);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError("");
    setSuccess("");

    try {
      if (form.typeDonIds.length === 0) {
        throw new Error("Sélectionne au moins un type de don");
      }

      const payload = mapFormToPayload(form);

      const savedPoint = editingId
        ? await pointCollecteService.update(editingId, payload)
        : await pointCollecteService.create(payload);

      if (form.autoGeneratePlanning) {
        await creneauService.generatePlanning(
          savedPoint.id,
          Number(form.planningYear)
        );
      }

      resetForm();
      await loadPoints();

      setSuccess(
        form.autoGeneratePlanning
          ? "Point enregistré et planning annuel généré avec succès."
          : "Point enregistré avec succès."
      );
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  async function handleEdit(point: PointCollecte) {
    setEditingId(point.id);
    setSuccess("");
    setForm({
      nom: point.nom,
      gouvernorat: point.gouvernorat,
      delegation: point.delegation,
      codePostal: point.codePostal,
      adressePostale: point.adressePostale,
      capacite: String(point.capacite),
      telephone: point.telephone || "",
      latitude: String(point.latitude),
      longitude: String(point.longitude),
      description: point.description || "",
      typeDonIds: point.typesDon?.map((t) => t.id) ?? [],
      autoGeneratePlanning: false,
      planningYear: String(new Date().getFullYear())
    });
    setMapCenter([point.latitude, point.longitude]);

    try {
      const data = await localisationService.getDelegations(point.gouvernorat);
      setDelegations(data);
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  async function handleDelete(id: number) {
    const confirmed = window.confirm("Supprimer ce point de collecte ?");
    if (!confirmed) return;

    try {
      await pointCollecteService.remove(id);
      await loadPoints();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  const filteredPoints = useMemo(() => {
    const search = query.toLowerCase();

    return points.filter((point) => {
      return (
        point.nom.toLowerCase().includes(search) ||
        point.gouvernorat.toLowerCase().includes(search) ||
        point.delegation.toLowerCase().includes(search) ||
        point.adressePostale.toLowerCase().includes(search)
      );
    });
  }, [points, query]);

  const markerPosition: [number, number] = [
    Number(form.latitude) || TUNISIA_CENTER[0],
    Number(form.longitude) || TUNISIA_CENTER[1]
  ];

  if (loading) return <Loader />;

  return (
    <div className="stack-lg">
      <PageHeader
        title="Points de collecte"
        description="Création et gestion des centres de collecte avec types de don et génération
        automatique de planning."
      />

      {error ? <div className="alert alert--error">{error}</div> : null}
      {success ? <div className="alert alert--success">{success}</div> : null}

      <Card
        title={editingId ? "Modifier un point" : "Ajouter un point"}
        subtitle="Sélectionne un gouvernorat, puis une délégation, ajuste le pointeur et enregistre."
      >
        <form onSubmit={handleSubmit} className="stack">
          <div className="grid-two">
            <InputField
              label="Nom"
              value={form.nom}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, nom: e.target.value }))
              }
              required
            />

            <InputField
              label="Capacité"
              type="number"
              min={1}
              value={form.capacite}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, capacite: e.target.value }))
              }
              required
            />
          </div>

          <div>
            <label className="field__label">Types de don proposés</label>
            <div
              style={{
                display: "flex",
                gap: 12,
                flexWrap: "wrap",
                marginTop: 10
              }}
            >
              {donationTypes.map((type) => (
                <label
                  key={type.id}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    gap: 8,
                    border: "1px solid #ddd",
                    borderRadius: 10,
                    padding: "10px 14px"
                  }}
                >
                  <input
                    type="checkbox"
                    checked={form.typeDonIds.includes(type.id)}
                    onChange={() => handleTypeDonToggle(type.id)}
                  />
                  <span>{type.label}</span>
                </label>
              ))}
            </div>
          </div>


          <div className="grid-two">
            <div>
              <label className="field__label">Gouvernorat</label>
              <select
                className="input"
                value={form.gouvernorat}
                onChange={(e) => handleGouvernoratChange(e.target.value)}
                required
              >
                <option value="">Choisir un gouvernorat</option>
                {gouvernorats.map((g) => (
                  <option key={g.nom} value={g.nom}>
                    {g.nom}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="field__label">Délégation</label>
              <select
                className="input"
                value={form.delegation}
                onChange={(e) => handleDelegationChange(e.target.value)}
                disabled={!form.gouvernorat}
                required
              >
                <option value="">Choisir une délégation</option>
                {delegations.map((d) => (
                  <option key={d.nom} value={d.nom}>
                    {d.nom}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="grid-two">
            <InputField
              label="Code postal"
              value={form.codePostal}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, codePostal: e.target.value }))
              }
              required
            />

            <InputField
              label="Téléphone"
              value={form.telephone}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, telephone: e.target.value }))
              }
            />
          </div>

          <InputField
            label="Adresse postale"
            value={form.adressePostale}
            onChange={(e) =>
              setForm((prev) => ({ ...prev, adressePostale: e.target.value }))
            }
            required
          />

          <div className="map-wrapper">
            <MapContainer
              center={mapCenter}
              zoom={7}
              style={{ height: "420px", width: "100%" }}
            >
              <TileLayer
                attribution='&copy; OpenStreetMap contributors'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              />
              <ChangeMapView center={mapCenter} />
              <LocationPicker
                position={markerPosition}
                onChange={(lat, lng) => setPosition(lat, lng)}
              />
            </MapContainer>
          </div>

          <div className="grid-two">
            <InputField
              label="Latitude"
              type="number"
              step="0.000001"
              value={form.latitude}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, latitude: e.target.value }))
              }
              required
            />

            <InputField
              label="Longitude"
              type="number"
              step="0.000001"
              value={form.longitude}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, longitude: e.target.value }))
              }
              required
            />
          </div>

          <TextAreaField
            label="Description"
            rows={3}
            value={form.description}
            onChange={(e) =>
              setForm((prev) => ({ ...prev, description: e.target.value }))
            }
          />

          <Card
            title="Planning automatique"
            subtitle="Ce bouton ne génère pas tout de suite. Il active la génération lors de l’enregistrement du point."
          >
            <div className="grid-two">
              <InputField
                label="Année du planning"
                type="number"
                min={new Date().getFullYear()}
                value={form.planningYear}
                onChange={(e) =>
                  setForm((prev) => ({ ...prev, planningYear: e.target.value }))
                }
              />

              <div style={{ display: "flex", alignItems: "end" }}>
                <Button
                  type="button"
                  variant={form.autoGeneratePlanning ? "primary" : "secondary"}
                  onClick={() =>
                    setForm((prev) => ({
                      ...prev,
                      autoGeneratePlanning: !prev.autoGeneratePlanning
                    }))
                  }
                  disabled={form.typeDonIds.length === 0}
                >
                  {form.autoGeneratePlanning
                    ? "Génération 12 mois activée"
                    : "Activer génération 12 mois"}
                </Button>
              </div>
            </div>
          </Card>

          <div className="inline-actions">
            <Button type="submit" disabled={saving}>
              {saving
                ? "Enregistrement..."
                : editingId
                ? "Mettre à jour"
                : "Créer le point"}
            </Button>

            {editingId ? (
              <Button
                type="button"
                variant="secondary"
                onClick={() => {
                  setEditingId(null);
                  setForm(initialForm);
                  setDelegations([]);
                  setMapCenter(TUNISIA_CENTER);
                }}
              >
                Annuler
              </Button>
            ) : null}
          </div>
        </form>
      </Card>

      <Card
        title="Centres enregistrés"
        actions={
          <div className="search-box">
            <input
              className="input"
              placeholder="Recherche par nom, gouvernorat, délégation..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
          </div>
        }
      >
        <DataTable
          data={filteredPoints}
          columns={[
            { header: "Nom", accessor: "nom" },
            { header: "Gouvernorat", accessor: "gouvernorat" },
            { header: "Délégation", accessor: "delegation" },
            { header: "Code postal", accessor: "codePostal" },
            { header: "Adresse", accessor: "adressePostale" },
             {
              header: "Types de don",
              render: (point) =>
                point.typesDon?.map((type) => type.label).join(", ") || "-"
            },
            {
              header: "Actions",
              render: (point) => (
                <div className="inline-actions">
                  <Button variant="secondary" onClick={() => handleEdit(point)}>
                    Éditer
                  </Button>
                  <Button
                    variant="danger"
                    onClick={() => handleDelete(point.id)}
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

const pointCollecteIcon = L.icon({
  iconUrl: markerIcon,
  iconRetinaUrl: markerIcon2x,
  shadowUrl: markerShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41],
  shadowAnchor: [12, 41]
});

function dedupeDelegations(items: DelegationOption[]): DelegationOption[] {
  const map = new Map<string, DelegationOption>();

  for (const item of items) {
    const key = [
      item.nom?.trim().toUpperCase(),
      item.codePostal ?? "",
      item.latitude ?? "",
      item.longitude ?? ""
    ].join("|");

    if (!map.has(key)) {
      map.set(key, item);
    }
  }

  return Array.from(map.values()).sort((a, b) =>
    a.nom.localeCompare(b.nom, "fr", { sensitivity: "base" })
  );
}