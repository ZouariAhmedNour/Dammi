
import { Navigate, Route, Routes } from 'react-router-dom';
import './App.css'
import { GuestOnlyRoute, HomeRedirect, ProtectedRoute } from './components/auth/RouteGuards';
import { LoginPage } from './pages/LoginPage';
import { RegisterPage } from './pages/RegisterPage';
import { DashboardLayout } from './components/layout/DashboardLayout';
import { AdminDashboardPage } from './pages/admin/AdminDashboardPage';
import { UsersPage } from './pages/admin/UsersPage';
import { PointsCollectePage } from './pages/admin/PointsCollectePage';
import { StocksPage } from './pages/agent/StocksPage';
import { DemandesPage } from './pages/agent/DemandesPage';
import { AgentDashboardPage } from './pages/agent/AgentDashboardPage';
import { UserHomePage } from './pages/user/UserHomePage';
import { AdminTypeSanguinPage } from './pages/admin/TypeSanguinPage';
import { AdminTypeDonPage } from './pages/admin/TypeDonPage';

function App() {
 return (
    <Routes>
      <Route path="/" element={<HomeRedirect />} />

      <Route element={<GuestOnlyRoute />}>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
      </Route>

      <Route element={<ProtectedRoute allowedRoles={["ADMIN"]} />}>
        <Route path="/admin" element={<DashboardLayout section="admin" />}>
          <Route index element={<AdminDashboardPage />} />
          <Route path="users" element={<UsersPage />} />
          <Route path="points" element={<PointsCollectePage />} />
          <Route path="types-don" element={<AdminTypeDonPage />} />
          <Route path="types-sanguins" element={<AdminTypeSanguinPage />} />
        </Route>
      </Route>

      <Route element={<ProtectedRoute allowedRoles={["AGENT", "ADMIN"]} />}>
        <Route path="/agent" element={<DashboardLayout section="agent" />}>
          <Route index element={<AgentDashboardPage />} />
          <Route path="stocks" element={<StocksPage />} />
          <Route path="demandes" element={<DemandesPage />} />
        </Route>
      </Route>

      <Route
        element={<ProtectedRoute allowedRoles={["USER", "AGENT", "ADMIN"]} />}
      >
        <Route path="/user" element={<DashboardLayout section="user" />}>
          <Route index element={<UserHomePage />} />
        </Route>
      </Route>

      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default App
