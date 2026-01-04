# =========================
# Build stage (frontend + backend together)
# =========================
FROM golang:1.23-alpine

WORKDIR /build

# Install build dependencies
# Added build-base and sqlite-dev for CGO/SQLite support
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    bash \
    build-base \
    sqlite-dev

# Install pnpm
RUN npm install -g pnpm

# Copy full Memos source
COPY . .

# -------------------------
# Build frontend
# -------------------------
WORKDIR /build/web
RUN pnpm install
RUN pnpm release

# -------------------------
# Build backend
# -------------------------
WORKDIR /build
RUN go mod download

# KEY CHANGES HERE:
# 1. CGO_ENABLED=1 (Required for SQLite)
# 2. Build path changed from ./cmd/memos to .
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o memos .


# =========================
# Runtime stage
# =========================
FROM alpine:latest

WORKDIR /usr/local/memos

# Added sqlite-libs so the binary can find the database driver at runtime
RUN apk add --no-cache tzdata sqlite-libs
ENV TZ="UTC"

# Copy binary and entrypoint from the build stage (index 0)
COPY --from=0 /build/memos /usr/local/memos/memos
COPY scripts/entrypoint.sh /usr/local/memos/
RUN chmod +x /usr/local/memos/entrypoint.sh

# Data directory
RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230

# This matches the binary name produced in the build stage
ENTRYPOINT ["./entrypoint.sh", "./memos"]