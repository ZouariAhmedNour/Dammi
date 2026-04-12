import { Droplets, FileWarning, HeartHandshake, LayoutDashboard, LogOut, MapPinned, Shield, Users, Warehouse, type LucideIcon } from "lucide-react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "../../contexts/useAuth";
import { Badge } from "../ui/Badge";

type SectionKey = "admin" | "agent" | "user";

interface MenuItem {
  label: string;
  to: string;
  icon: LucideIcon;
}

const menuBySection: Record<SectionKey, MenuItem[]> = {
  admin: [
    { label: "Dashboard", to: "/admin", icon: LayoutDashboard },
    { label: "Utilisateurs", to: "/admin/users", icon: Users },
    { label: "Points de collecte", to: "/admin/points", icon: MapPinned },
    { label: "Types de don", to: "/admin/types-don", icon: HeartHandshake },
    { label: "Types sanguins", to: "/admin/types-sanguins", icon: Droplets },
    { label: "Questions", to: "/admin/questions", icon: FileWarning },
    { label: "Questionnaires", to: "/admin/questionnaires", icon: HeartHandshake }
  ],
  agent: [
    { label: "Dashboard", to: "/agent", icon: LayoutDashboard },
    { label: "Stocks sanguins", to: "/agent/stocks", icon: Warehouse },
    { label: "Demandes", to: "/agent/demandes", icon: FileWarning }
  ],
  user: [{ label: "Mon espace", to: "/user", icon: HeartHandshake }]
};

const titleBySection: Record<SectionKey, string> = {
  admin: "Administration",
  agent: "Banque de sang",
  user: "Espace donneur"
};

export function DashboardLayout({ section }: { section: SectionKey }) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const menu = menuBySection[section];

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="sidebar__brand">
          <div className="brand__icon">
            <Droplets size={22} />
          </div>
          <div>
            <h1>Dammi</h1>
            <p>{titleBySection[section]}</p>
          </div>
        </div>

        <nav className="sidebar__nav">
          {menu.map((item) => {
            const Icon = item.icon;

            return (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.to === `/${section}`}
                className={({ isActive }) =>
                  isActive ? "sidebar__link is-active" : "sidebar__link"
                }
              >
                <Icon size={18} />
                <span>{item.label}</span>
              </NavLink>
            );
          })}
        </nav>

        <div className="sidebar__footer">
          <div className="profile-card">
            <div className="profile-card__avatar">
              {user?.prenom?.[0] || user?.email?.[0] || "D"}
            </div>
            <div>
              <strong>
                {[user?.prenom, user?.nom].filter(Boolean).join(" ") || "Compte"}
              </strong>
              <div className="muted small">{user?.email}</div>
            </div>
          </div>

          <button
            className="button button--ghost button--block"
            onClick={() => {
              logout();
              navigate("/login", { replace: true });
            }}
          >
            <LogOut size={16} />
            Déconnexion
          </button>
        </div>
      </aside>

      <div className="content-shell">
        <header className="topbar">
          <div className="topbar__user">
            <Shield size={16} />
            <span>{user?.email}</span>
            <Badge>{user?.role}</Badge>
          </div>
        </header>

        <main className="page-body">
          <Outlet />
        </main>
      </div>
    </div>
  );
}