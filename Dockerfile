# =========================
# Build stage
# =========================
FROM golang:1.23-alpine

# Use /src instead of /build because 'build' is in your .gitignore
WORKDIR /src

# 1. Install system dependencies
RUN apk add --no-cache nodejs npm git bash build-base sqlite-dev
RUN npm install -g pnpm

# 2. Copy the entire repository
COPY . .

# -------------------------
# Build frontend
# -------------------------
# Step into the directory (This matches your find command exactly)
WORKDIR /src/app/memos/web

# We use 'pnpm install' and 'pnpm run build' (standard for Memos)
RUN pnpm install
RUN pnpm run build

# -------------------------
# Build backend
# -------------------------
WORKDIR /src/app/memos
RUN go mod download

# Build the binary to a unique name in the root
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos_binary .


# =========================
# Runtime stage
# =========================
FROM alpine:latest

RUN apk add --no-cache tzdata sqlite-libs
ENV TZ="UTC"

WORKDIR /usr/local/memos

# Copy the binary from the first stage
COPY --from=0 /memos_binary /usr/local/memos/memos

# Setup data directory
RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

# Configuration
EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230
ENV MEMOS_DATA=/var/opt/memos

ENTRYPOINT ["/usr/local/memos/memos"]