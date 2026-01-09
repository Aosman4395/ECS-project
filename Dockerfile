# =========================
# Build stage
# =========================
FROM golang:1.25-alpine AS builder

WORKDIR /src

# 1. Install system dependencies
RUN apk add --no-cache nodejs npm git bash build-base sqlite-dev

# 2. Install latest pnpm
RUN npm install -g pnpm@latest

# 3. COPY EVERYTHING FIRST
# This brings the 'web' folder and 'go.mod' into /src
COPY . .

# -------------------------
# Build frontend
# -------------------------
WORKDIR /src/web
# We are now in /src/web, where package.json lives
RUN pnpm install
RUN pnpm run build

# -------------------------
# Build backend
# -------------------------
WORKDIR /src
# We are now in /src, where go.mod and main.go live
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