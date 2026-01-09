########################################
# 1️⃣ FRONTEND BUILD (PNPM / Vite)
########################################
FROM node:20-alpine AS frontend-builder

# Enable pnpm
RUN corepack enable

WORKDIR /src/app/memos/web

# Copy dependency manifests first (cache friendly)
COPY app/memos/web/package.json app/memos/web/pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy rest of frontend
COPY app/memos/web ./

# Build frontend
RUN pnpm build


########################################
# 2️⃣ BACKEND BUILD (Go)
########################################
FROM golang:1.25-alpine AS backend-builder

WORKDIR /src/app/memos

# Required for CGO
RUN apk add --no-cache git build-base

# Copy Go dependency files first
COPY app/memos/go.mod app/memos/go.sum ./
RUN go mod download

# Copy backend source
COPY app/memos ./

# Build Go binary
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos ./cmd/memos


########################################
# 3️⃣ FINAL RUNTIME IMAGE
########################################
FROM alpine:3.19

WORKDIR /app

# Required runtime libs for CGO
RUN apk add --no-cache ca-certificates tzdata libc6-compat

# Copy Go binary
COPY --from=backend-builder /memos /usr/local/bin/memos

# Copy built frontend into backend expected location
COPY --from=frontend-builder /src/app/memos/web/dist /app/web/dist

# Expose Memos port
EXPOSE 5230

# Run Memos
ENTRYPOINT ["memos"]
