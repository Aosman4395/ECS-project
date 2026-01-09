# =========================
# Build stage
# =========================
FROM golang:1.25-alpine AS builder

WORKDIR /src

# 1. Install system dependencies
RUN apk add --no-cache nodejs npm git bash build-base sqlite-dev

# 2. Install LATEST pnpm
RUN npm install -g pnpm@latest

# 3. Copy everything from the context
# Because the context is 'app/memos', this copies go.mod and the web folder
# directly into /src
COPY . .

# -------------------------
# Build frontend
# Based on your find command, 'web' is inside 'app/memos'
# In Docker context 'app/memos', 'web' is now at the top level.
# -------------------------
WORKDIR /src/web
RUN pnpm install
RUN pnpm run build

# -------------------------
# Build backend
# In Docker context 'app/memos', 'go.mod' is now at /src
# -------------------------
WORKDIR /src
RUN go mod download

# Build the binary with CGO enabled for SQLite
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos_binary .

# =========================
# Runtime stage
# =========================
FROM alpine:latest
RUN apk add --no-cache tzdata sqlite-libs
ENV TZ=UTC
WORKDIR /usr/local/memos

# Copy the binary from the builder stage
COPY --from=builder /memos_binary ./memos

# Setup data directory
RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

# Config
EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230
ENV MEMOS_DATA=/var/opt/memos

ENTRYPOINT ["/usr/local/memos/memos"]