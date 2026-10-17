# Service Booking & Management API

REST API for the **Service Booking and Management System** final project (Full Stack Web Development, Dibimbing).
Customers browse services, pick an available schedule and book it. Admins manage services, schedules, customers, bookings, payments and reports.

## Tech Stack

| Layer | Technology |
| --- | --- |
| Runtime | Node.js 20+ |
| Framework | Express 4 |
| Database | PostgreSQL 16/17 |
| ORM | Sequelize 6 + sequelize-cli |
| Auth | JWT (access + refresh token), bcryptjs |
| Validation | Zod |
| Docs | OpenAPI 3 + Swagger UI |
| Testing | Jest + Supertest |

## Getting Started

```bash
cd backend
npm install
cp .env.example .env          # then set DATABASE_URL and JWT secrets
createdb -U postgres booking_db
npm run db:migrate            # create tables from src/database/migrations
npm run db:seed               # demo data (resets all tables)
npm run dev                   # http://localhost:5000
```

- Swagger UI: `http://localhost:5000/api/docs`
- OpenAPI JSON: `http://localhost:5000/api/docs.json`
- Health check: `http://localhost:5000/health`

### Demo accounts (after seeding)

| Role | Email | Password |
| --- | --- | --- |
| Admin | admin@booking.com | Admin12345 |
| Customer | budi@example.com | User12345 |
| Customer | siti@example.com | User12345 |

### Run with Docker

```bash
cd backend
docker compose up --build
docker compose exec api npx sequelize-cli db:seed:all   # optional demo data
```

## Scripts

| Script | Description |
| --- | --- |
| `npm run dev` | Start with nodemon |
| `npm start` | Start in production mode |
| `npm test` | Run unit and integration tests |
| `npm run db:migrate` | Apply pending migrations |
| `npm run db:migrate:undo` | Revert all migrations |
| `npm run db:seed` | Reset and insert demo data |
| `npm run db:reset` | Undo all, migrate and seed again |

## Project Structure

```
backend/
├── .sequelizerc       sequelize-cli paths
├── src/
│   ├── app.js         Express app and global middleware
│   ├── server.js      HTTP server bootstrap
│   ├── config/        env validation, sequelize-cli config
│   ├── models/        Sequelize models and associations
│   ├── database/      migrations and seeders
│   ├── docs/          OpenAPI specification
│   ├── middlewares/   authenticate, authorize, validate, rate limit, errors
│   ├── modules/       auth, users, categories, services, schedules, bookings, payments, reports
│   │   └── <module>/  *.routes.js → *.controller.js → *.service.js (+ *.schema.js)
│   ├── routes/        /api/v1 router
│   └── utils/         helpers (pagination, time, jwt, csv, ...)
└── tests/             unit and integration tests
```

## Entity Relationship

```
User 1──N Booking N──1 Schedule N──1 Service N──1 Category
Booking 1──1 Payment
Booking 1──N BookingStatusLog N──1 User (changed by)
User 1──N RefreshToken
```

## Key Business Rules

- A booking is created inside a database transaction that locks the schedule row (`lock: transaction.LOCK.UPDATE`), so two customers cannot take the last seat at the same time.
- A customer cannot hold two active bookings whose times overlap (`start < otherEnd AND end > otherStart`).
- Schedules of the same service cannot overlap; `endTime` is computed from the service duration.
- Booking status flow: `PENDING → CONFIRMED → COMPLETED`, and `PENDING/CONFIRMED → CANCELLED`.
- Customers may cancel at least 2 hours before the schedule; cancelling frees the seat and refunds a paid payment.
- Services are soft deleted (`paranoid`), so booking history keeps its service data.
- All times are in WIB (UTC+7).
