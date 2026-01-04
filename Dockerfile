# =========================
# Build stage (frontend + backend together)
# =========================
FROM golang:1.25-alpine

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    bash

# Install pnpm
RUN npm install -g pnpm

# Copy full Memos source
COPY . .

# -------------------------
# Build frontend (THIS IS THE KEY)
# -------------------------
WORKDIR /build/web
RUN pnpm install
RUN pnpm release

# -------------------------
# Build backend (frontend now exists at web/dist)
# -------------------------
WORKDIR /build
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o memos ./cmd/memos


# =========================
# Runtime stage
# =========================
FROM alpine:latest

WORKDIR /usr/local/memos

RUN apk add --no-cache tzdata
ENV TZ="UTC"

# Copy binary and entrypoint
COPY --from=0 /build/memos /usr/local/memos/memos
COPY scripts/entrypoint.sh /usr/local/memos/
RUN chmod +x /usr/local/memos/entrypoint.sh

# Data directory
RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230

ENTRYPOINT ["./entrypoint.sh", "./memos"]

