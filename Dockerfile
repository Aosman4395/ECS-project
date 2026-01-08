# =========================
# Build stage
# =========================
FROM golang:1.25-alpine AS builder

WORKDIR /src

# 1. Install system dependencies (CGO + SQLite + frontend tooling)
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    bash \
    build-base \
    sqlite-dev

# 2. Pin pnpm to v9 for stability
RUN npm install -g pnpm@9

# 3. Copy entire repo from the root context
COPY . .

# -------------------------
# Build frontend
# -------------------------
WORKDIR /src/app/memos/web
RUN pnpm install
RUN pnpm run build

# -------------------------
# Build backend
# -------------------------
WORKDIR /src/app/memos
RUN go mod download

# Build the binary with CGO enabled for SQLite support
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos_binary .

# =========================
# Runtime stage
# =========================
FROM alpine:latest

# Runtime dependencies for SQLite and Timezones
RUN apk add --no-cache tzdata sqlite-libs
ENV TZ=UTC

WORKDIR /usr/local/memos

# Copy the binary from the builder stage
COPY --from=builder /memos_binary ./memos

# Setup data directory for SQLite persistence
RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

# App configuration
EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230
ENV MEMOS_DATA=/var/opt/memos

# Start the application
ENTRYPOINT ["/usr/local/memos/memos"]
