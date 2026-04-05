import { useState } from "react";
import { resolveHomeRoute } from "../lib/auth";
import { getApiErrorMessage } from "../lib/helpers";
import { Card } from "../components/ui/Card";
import { Button } from "../components/ui/Button";
import { InputField } from "../components/ui/Field";
import { Droplets } from "lucide-react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/useAuth";

export function LoginPage() {
  const { login, loading } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    email: "",
    password: ""
  });
  const [error, setError] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    try {
      const session = await login(form);
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
            <h1>Dammi</h1>
            <p>Votre don est une promesse de vie.</p>
          </div>
        </div>

        <form className="auth-form" onSubmit={handleSubmit}>
          <InputField
            label="Email"
            type="email"
            placeholder="nom@exemple.com"
            value={form.email}
            onChange={(e) =>
              setForm((prev) => ({ ...prev, email: e.target.value }))
            }
            required
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
            {loading ? "Connexion..." : "Se connecter"}
          </Button>
        </form>

        <p className="auth-footer">
          Pas encore de compte ? <Link to="/register">Créer un compte</Link>
        </p>
      </Card>
    </div>
  );
}