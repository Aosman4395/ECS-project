# =========================
# Build stage
# =========================
FROM golang:1.25-alpine AS builder

WORKDIR /src

# System dependencies (CGO + SQLite + frontend tooling)
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    bash \
    build-base \
    sqlite-dev

# Pin pnpm to v9 (v10 has known CI issues)
RUN npm install -g pnpm@9

# Copy entire repo (build context = repo root)
COPY . .

# -------------------------
# Build frontend
# package.json lives here
# -------------------------
WORKDIR /src/app/memos/web
RUN pnpm install
RUN pnpm run build

# -------------------------
# Build backend
# main.go lives in cmd/memos
# -------------------------
WORKDIR /src/app/memos
RUN go mod download

RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos_binary ./cmd/memos

# =========================
# Runtime stage
# =========================
FROM alpine:latest

# Runtime deps for SQLite
RUN apk add --no-cache tzdata sqlite-libs
ENV TZ=UTC

WORKDIR /usr/local/memos

# Copy compiled binary
COPY --from=builder /memos_binary ./memos

# Persistent data directory
RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

# App config
EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230
ENV MEMOS_DATA=/var/opt/memos

# Start Memos
ENTRYPOINT ["/usr/local/memos/memos"]
