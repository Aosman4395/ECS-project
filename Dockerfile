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
COPY . .

# --- DEBUG: This will show us exactly where package.json is in the logs ---
RUN find . -name package.json

# -------------------------
# Build frontend
# -------------------------
# We look for the web folder. If you are building from 'app/memos', 
# then 'web' is at the root of the context.
WORKDIR /src/web
RUN pnpm install
RUN pnpm run build

# -------------------------
# Build backend
# -------------------------
WORKDIR /src
RUN go mod download

# Build the binary
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos_binary .

# =========================
# Runtime stage
# =========================
FROM alpine:latest
RUN apk add --no-cache tzdata sqlite-libs
ENV TZ=UTC
WORKDIR /usr/local/memos

COPY --from=builder /memos_binary ./memos

RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230
ENV MEMOS_DATA=/var/opt/memos

ENTRYPOINT ["/usr/local/memos/memos"]