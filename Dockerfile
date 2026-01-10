########################################
# 1️⃣ FRONTEND BUILD (PNPM)
########################################
FROM node:20-alpine AS frontend-builder

RUN corepack enable

WORKDIR /src/app/memos/web

# Copy dependency files
COPY app/memos/web/package.json app/memos/web/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy frontend source
COPY app/memos/web ./

# Build frontend
RUN pnpm build


########################################
# 2️⃣ BACKEND BUILD (Go 1.25)
########################################
FROM golang:1.25-alpine AS backend-builder

WORKDIR /src/app/memos

# Required for CGO
RUN apk add --no-cache git build-base

# Copy Go dependency files
COPY app/memos/go.mod app/memos/go.sum ./
RUN go mod download

# Copy backend source
COPY app/memos ./

# 🔑 COPY FRONTEND DIST INTO BACKEND (CRITICAL)
COPY --from=frontend-builder \
  /src/app/memos/web/dist \
  /src/app/memos/server/router/frontend/dist

# Optional sanity check (remove later)
RUN ls server/router/frontend/dist

# Build Go binary
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos ./cmd/memos


########################################
# 3️⃣ FINAL RUNTIME IMAGE
########################################
FROM alpine:3.19

WORKDIR /app

# Runtime deps for CGO
RUN apk add --no-cache ca-certificates tzdata libc6-compat

# Copy backend binary
COPY --from=backend-builder /memos /usr/local/bin/memos

# Expose Memos port
EXPOSE 5230

# Start Memos
ENTRYPOINT ["memos"]
