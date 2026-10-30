import { lazy, Suspense } from 'react';
import { Route, Routes } from 'react-router-dom';
import MainLayout from '../layouts/MainLayout';
import ProtectedRoute from './ProtectedRoute';
import GuestRoute from './GuestRoute';
import { PageLoader } from '../components/ui/Spinner';
import HomePage from '../pages/public/HomePage';
import ServicesPage from '../pages/public/ServicesPage';
import ServiceDetailPage from '../pages/public/ServiceDetailPage';
import LoginPage from '../pages/public/LoginPage';
import RegisterPage from '../pages/public/RegisterPage';
import AuthCallbackPage from '../pages/public/AuthCallbackPage';
import { ForbiddenPage, NotFoundPage } from '../pages/public/StatusPages';
import MyBookingsPage from '../pages/user/MyBookingsPage';
import BookingDetailPage from '../pages/user/BookingDetailPage';
import ProfilePage from '../pages/user/ProfilePage';

// Admin pages are split into a separate bundle because customers never need them
const AdminLayout = lazy(() => import('../layouts/AdminLayout'));
const DashboardPage = lazy(() => import('../pages/admin/DashboardPage'));
const AdminBookingsPage = lazy(() => import('../pages/admin/BookingsPage'));
const AdminBookingDetailPage = lazy(() => import('../pages/admin/BookingDetailPage'));
const AdminServicesPage = lazy(() => import('../pages/admin/ServicesPage'));
const AdminCategoriesPage = lazy(() => import('../pages/admin/CategoriesPage'));
const AdminSchedulesPage = lazy(() => import('../pages/admin/SchedulesPage'));
const AdminCustomersPage = lazy(() => import('../pages/admin/CustomersPage'));
const AdminReportsPage = lazy(() => import('../pages/admin/ReportsPage'));

export default function AppRoutes() {
  return (
    <Suspense fallback={<PageLoader />}>
      <Routes>
        <Route element={<MainLayout />}>
          <Route index element={<HomePage />} />
          <Route path="services" element={<ServicesPage />} />
          <Route path="services/:id" element={<ServiceDetailPage />} />

          <Route element={<GuestRoute />}>
            <Route path="login" element={<LoginPage />} />
            <Route path="register" element={<RegisterPage />} />
          </Route>
          {/* Outside GuestRoute: the session is created on this page */}
          <Route path="login/callback" element={<AuthCallbackPage />} />

          <Route element={<ProtectedRoute roles={['USER']} />}>
            <Route path="my-bookings" element={<MyBookingsPage />} />
            <Route path="my-bookings/:id" element={<BookingDetailPage />} />
          </Route>

          <Route element={<ProtectedRoute />}>
            <Route path="profile" element={<ProfilePage />} />
          </Route>

          <Route path="forbidden" element={<ForbiddenPage />} />
          <Route path="*" element={<NotFoundPage />} />
        </Route>

        <Route path="admin" element={<ProtectedRoute roles={['ADMIN']} />}>
          <Route element={<AdminLayout />}>
            <Route index element={<DashboardPage />} />
            <Route path="bookings" element={<AdminBookingsPage />} />
            <Route path="bookings/:id" element={<AdminBookingDetailPage />} />
            <Route path="services" element={<AdminServicesPage />} />
            <Route path="categories" element={<AdminCategoriesPage />} />
            <Route path="schedules" element={<AdminSchedulesPage />} />
            <Route path="customers" element={<AdminCustomersPage />} />
            <Route path="reports" element={<AdminReportsPage />} />
          </Route>
        </Route>
      </Routes>
    </Suspense>
  );
}
