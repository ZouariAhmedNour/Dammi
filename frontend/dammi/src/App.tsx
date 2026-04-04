import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from './assets/vite.svg'
import heroImg from './assets/hero.png'
import './App.css'

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
