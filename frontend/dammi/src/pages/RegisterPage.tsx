import { useState } from "react";
import { Card } from "../components/ui/Card";
import { InputField } from "../components/ui/Field";
import { resolveHomeRoute } from "../lib/auth";
import { getApiErrorMessage } from "../lib/helpers";
import { Button } from "../components/ui/Button";
import { useNavigate } from "react-router-dom";
import { Droplets, Link } from "lucide-react";
import { useAuth } from "../contexts/useAuth";

export function RegisterPage() {
  const { register, loading } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    prenom: "",
    nom: "",
    email: "",
    phone: "",
    password: ""
  });
  const [error, setError] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    try {
      const session = await register(form);
      navigate(resolveHomeRoute(session.user.role), { replace: true });
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  return (
    <div className="auth-page">
      <Card className="auth-card">
        <div className="auth-brand">
          <div className="brand__icon large">
            <Droplets size={28} />
          </div>
          <div>
            <h1>Créer un compte</h1>
            <p>Commencez votre parcours dans Dammi.</p>
          </div>
        </div>

        <form className="auth-form" onSubmit={handleSubmit}>
          <div className="grid-two">
            <InputField
              label="Prénom"
              placeholder="Jean"
              value={form.prenom}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, prenom: e.target.value }))
              }
              required
            />

            <InputField
              label="Nom"
              placeholder="Dupont"
              value={form.nom}
              onChange={(e) =>
                setForm((prev) => ({ ...prev, nom: e.target.value }))
              }
              required
            />
          </div>

          <InputField
            label="Email"
            type="email"
            placeholder="jean.dupont@exemple.com"
            value={form.email}
            onChange={(e) =>
              setForm((prev) => ({ ...prev, email: e.target.value }))
            }
            required
          />

          <InputField
            label="Téléphone"
            placeholder="+221771234567"
            value={form.phone}
            onChange={(e) =>
              setForm((prev) => ({ ...prev, phone: e.target.value }))
            }
          />

          <InputField
            label="Mot de passe"
            type="password"
            placeholder="••••••••"
            value={form.password}
            onChange={(e) =>
              setForm((prev) => ({ ...prev, password: e.target.value }))
            }
            required
          />

          {error ? <div className="alert alert--error">{error}</div> : null}

          <Button type="submit" block disabled={loading}>
            {loading ? "Inscription..." : "S'inscrire"}
          </Button>
        </form>

        <p className="auth-footer">
          Déjà un compte ? <Link to="/login">Se connecter</Link>
        </p>
      </Card>
    </div>
  );
}