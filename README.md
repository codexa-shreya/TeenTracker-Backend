# TeenTrack — Backend REST API 🚀

[![Render Status](https://img.shields.io/badge/Render-Deployed-46E3B7?style=flat&logo=render&logoColor=white)](https://teentracker-backend.onrender.com/api/health)
[![API Status](https://img.shields.io/badge/API-Live%20&%20Healthy-success)](https://teentracker-backend.onrender.com/api/health)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=flat&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![Express.js](https://img.shields.io/badge/Express.js-4.21-000000?style=flat&logo=express&logoColor=white)](https://expressjs.com/)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?style=flat&logo=supabase&logoColor=white)](https://supabase.com/)

REST API service and business logic for **TeenTrack — Teenager Expense Tracker**, built with **Node.js**, **Express.js**, and **Supabase PostgreSQL** following strict **MVC architecture**.

---

## 🌐 Live Deployed API

- **Deployed Base URL:** [`https://teentracker-backend.onrender.com/api`](https://teentracker-backend.onrender.com/api)
- **Health Check Endpoint:** [`https://teentracker-backend.onrender.com/api/health`](https://teentracker-backend.onrender.com/api/health)
- **System Status Endpoint:** [`https://teentracker-backend.onrender.com/api/system/status`](https://teentracker-backend.onrender.com/api/system/status)
- **Root Welcome:** [`https://teentracker-backend.onrender.com/`](https://teentracker-backend.onrender.com/)

> **Note:** The backend is deployed on Render free tier. On cold starts after inactivity, the first request may take ~30–50 seconds to spin up.

---

## 🏗️ Architecture

```
routes/ ──► middleware/ ──► controllers/ ──► services/ ──► models/ ──► Supabase PostgreSQL
```

- **Routes (`src/routes/`):** API endpoint routing and parameter passing.
- **Middleware (`src/middleware/`):** Security headers (Helmet), Rate Limiting, CORS, Zod Request Validation, Centralized Error Handling.
- **Controllers (`src/controllers/`):** HTTP request parsing and response formatting.
- **Services (`src/services/`):** Core business logic, analytics calculations, deterministic smart spending recommendation engine.
- **Models (`src/models/`):** Data access layer interfacing directly with Supabase PostgreSQL.

---

## 🛠️ Tech Stack & Security

- **Runtime:** Node.js (v18+)
- **Framework:** Express.js (ES Modules)
- **Database:** Supabase PostgreSQL
- **Security:**
  - `bcrypt` for one-way password hashing (salt rounds: 10)
  - `jsonwebtoken` (JWT) for stateless authenticated sessions
  - `helmet` for secure HTTP headers
  - `cors` with restricted origin whitelist
  - `express-rate-limit` for DDoS and brute-force protection
  - `zod` for strict request payload validation
  - Centralized error handler without production stack trace leaks

---

## 📋 Endpoints Overview

**Base URLs:**
- **Production:** `https://teentracker-backend.onrender.com/api`
- **Local Development:** `http://localhost:5000/api`

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/health` | Health check & uptime | No |
| `GET` | `/api/system/status` | System diagnostics & security audit | No |
| `GET` | `/api/categories` | List expense & income categories | Optional |
| `POST` | `/api/auth/register` | Register new user account | No |
| `POST` | `/api/auth/login` | Login & receive JWT token | No |
| `GET` | `/api/auth/me` | Get current authenticated user | Yes |
| `GET` | `/api/transactions` | Query & filter transactions | Yes |
| `POST` | `/api/transactions` | Create new transaction | Yes |
| `GET` | `/api/analytics/summary` | Analytics & KPI summary | Yes |
| `GET` | `/api/budgets` | User budgets & category limits | Yes |
| `GET` | `/api/savings-goals` | Savings goals progress | Yes |
| `GET` | `/api/recommendations` | Smart money recommendations | Yes |

---

## ⚙️ Environment Variables (`.env`)

```env
PORT=5000
NODE_ENV=development
CLIENT_URL=http://localhost:5173

# Supabase PostgreSQL (Keep SERVICE_ROLE_KEY backend-only!)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Authentication
JWT_SECRET=your-secure-jwt-secret-at-least-32-characters
JWT_EXPIRES_IN=7d
```

---

## 🚀 Running Locally

```powershell
# Install dependencies
npm install

# Start development server with hot-reload
npm run dev

# Start production server
npm start
```
