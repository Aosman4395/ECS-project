# =========================
# Build stage
# =========================
FROM golang:1.23-alpine

WORKDIR /src

# System deps (CGO + SQLite + frontend tooling)
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    bash \
    build-base \
    sqlite-dev

# Pin pnpm to v9 (v10 has known issues)
RUN npm install -g pnpm@9

# Copy entire repo (build context = repo root)
COPY . .

# -------------------------
# Build frontend
# package.json lives HERE
# -------------------------
WORKDIR /src/app/memos/web
RUN pnpm install
RUN pnpm run build

# -------------------------
# Build backend
# go.mod + main.go live HERE
# -------------------------
WORKDIR /src/app/memos
RUN go mod download

RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos_binary .

# =========================
# Runtime stage
# =========================
FROM alpine:latest

# Runtime deps for SQLite
RUN apk add --no-cache tzdata sqlite-libs
ENV TZ=UTC

WORKDIR /usr/local/memos

# Copy compiled binary
COPY --from=0 /memos_binary ./memos

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

