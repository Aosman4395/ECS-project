# =========================
# Build stage
# =========================
FROM golang:1.25-alpine AS builder

# This is where we will work inside the container
WORKDIR /src

# 1. Install system dependencies
RUN apk add --no-cache nodejs npm git bash build-base sqlite-dev
RUN npm install -g pnpm@9

# 2. Copy everything from the build context (app/memos) into /src
# Since your context is 'app/memos', this copies main.go, go.mod, etc.
COPY . .

# -------------------------
# Build frontend
# -------------------------
WORKDIR /src/web
RUN pnpm install
RUN pnpm run build

# -------------------------
# Build backend
# We move back to /src because that's where the Go files are now
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