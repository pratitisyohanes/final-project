import { Navigate, Outlet } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';

// Login and register pages are only for visitors who are not logged in
export default function GuestRoute() {
  const user = useAuthStore((state) => state.user);
  if (user) return <Navigate to={user.role === 'ADMIN' ? '/admin' : '/my-bookings'} replace />;
  return <Outlet />;
}
