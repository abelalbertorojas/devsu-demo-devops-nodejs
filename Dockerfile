# ─── Stage 1: full install (dependencias, uso en test ) ───────────
FROM node:18.15.0-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# ─── Stage 2: production-only deps ────────────────────────────────────────────
FROM node:18.15.0-alpine AS prod-deps
WORKDIR /app
COPY package.json package-lock.json ./
# dotenv is declared as devDependency but required at runtime (database.js).
# Install it explicitly until it is moved to dependencies in package.json.
RUN npm ci --omit=dev && \
    npm install --no-save dotenv@16.0.3

# ─── Stage 3: final runtime image ─────────────────────────────────────────────
FROM node:18.15.0-alpine AS runner

# Non-root user for least-privilege execution
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Persistent directory for the SQLite database file
RUN mkdir -p /app/data && chown appuser:appgroup /app/data

# Copy lean node_modules from prod-deps stage
COPY --from=prod-deps --chown=appuser:appgroup /app/node_modules ./node_modules

# Copy application source (no test files, no config cruft)
COPY --chown=appuser:appgroup package.json  ./
COPY --chown=appuser:appgroup index.js      ./
COPY --chown=appuser:appgroup users/        ./users/
COPY --chown=appuser:appgroup shared/       ./shared/

USER appuser

# ── Runtime environment variables ─────────────────────────────────────────────
# Override these at `docker run` time via -e / --env-file.
ENV NODE_ENV=production \
    DATABASE_NAME=/app/data/db.sqlite \
    DATABASE_USER=user \
    DATABASE_PASSWORD=password

EXPOSE 8000

# ── Health check ───────────────────────────────────────────────────────────────
# Uses the existing /api/users endpoint; start-period covers sequelize.sync().
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD wget -qO- http://localhost:8000/api/users || exit 1

# SQLite data survives container restarts when this volume is mounted
VOLUME ["/app/data"]

CMD ["node", "index.js"]
