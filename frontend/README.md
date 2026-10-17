# Service Booking Web (BookEase)

React frontend for the **Service Booking and Management System** final project. Customers browse services, pick an available slot and track their bookings. Admins manage services, schedules, bookings and customers, and read reports from an admin panel.

## Tech Stack

| Concern | Library |
| --- | --- |
| UI | React 18 + Vite |
| Styling | Tailwind CSS (responsive, mobile first) |
| Routing | React Router 6 with role-based route guards |
| Server state | TanStack Query (cache, loading, refetch after mutation) |
| Client state | Zustand (logged-in user and tokens) |
| HTTP | Axios with token and refresh interceptors |
| Forms | React Hook Form + Zod |
| Charts | Recharts |
| Notifications | react-hot-toast |

## Getting Started

The backend in `../backend` must be running first.

```bash
cd frontend
npm install
cp .env.example .env     # VITE_API_URL=http://localhost:5000/api/v1
npm run dev              # http://localhost:5173
```

| Script | Description |
| --- | --- |
| `npm run dev` | Start the dev server |
| `npm run build` | Build to `dist/` |
| `npm run preview` | Serve the production build locally |

Demo accounts (from the backend seeder): `admin@booking.com / Admin12345`, `budi@example.com / User12345`.

## Folder Structure

```
src/
├── api/          Axios client and one file per backend module
├── components/   Shared components; ui/ holds generic building blocks
│   ├── admin/    Admin form modals
│   └── charts/   Recharts wrappers
├── hooks/        TanStack Query hooks, URL filters, logout, session bootstrap
├── layouts/      MainLayout (public + customer) and AdminLayout
├── pages/        public/, user/ and admin/ pages
├── routes/       Route table and route guards
├── schemas/      Zod form schemas (same rules as the backend)
├── store/        Zustand auth store
└── utils/        Formatting, error helpers, constants, file download
```

## Pages

| Route | Access | Description |
| --- | --- | --- |
| `/` | Public | Hero, categories, latest services |
| `/services` | Public | Catalog with search, category, price filter, sort and pagination |
| `/services/:id` | Public | Detail, weekly slot picker and booking |
| `/login`, `/register` | Guest | Authentication |
| `/my-bookings` | Customer | Booking history with status tabs and period filter |
| `/my-bookings/:id` | Customer | Detail, status history and cancellation |
| `/profile` | Logged in | Update profile and password |
| `/admin` | Admin | Dashboard with stats, revenue chart, pending bookings |
| `/admin/bookings` | Admin | Search and filter bookings, update status, record payment |
| `/admin/services`, `/admin/categories` | Admin | CRUD |
| `/admin/schedules` | Admin | Add, generate, edit, close and delete slots |
| `/admin/customers` | Admin | Customer list, detail and activation |
| `/admin/reports` | Admin | Top services, busiest schedules, revenue, CSV download |

## Authentication Flow

1. Login stores `user`, `accessToken` and `refreshToken` in Zustand. Only `user` and `refreshToken` are persisted to `localStorage`.
2. On page load, `useSessionBootstrap` exchanges the refresh token for a new access token before rendering.
3. The Axios request interceptor adds `Authorization: Bearer <accessToken>`.
4. On a `401`, the response interceptor refreshes once (shared between parallel requests) and retries. If refreshing fails, the session is cleared.
5. `ProtectedRoute` redirects guests to `/login` and users with the wrong role to `/forbidden`. The backend still checks every role.

## Deployment

**Vercel**: import the repo, set the root directory to `frontend`, add `VITE_API_URL=https://<backend-domain>/api/v1`. `vercel.json` rewrites all paths to `index.html`. Add the Vercel domain to the backend `CORS_ORIGIN`.

**Docker**:

```bash
docker build -t booking-web --build-arg VITE_API_URL=http://localhost:5000/api/v1 .
docker run -p 8080:80 booking-web
```

Or run the full stack from `backend/` with `docker compose up --build` (web on port 8080).
