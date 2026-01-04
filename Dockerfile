# =========================
# Build stage
# =========================
FROM golang:1.23-alpine

# Set the base directory inside the container
WORKDIR /src

# 1. Install system dependencies
RUN apk add --no-cache nodejs npm git bash build-base sqlite-dev
RUN npm install -g pnpm

# 2. Copy the entire repository into the container
# This ensures /src/app/memos/web exists
COPY . .

# -------------------------
# Build frontend
# -------------------------
# Step into the exact directory found by your 'find' command
WORKDIR /src/app/memos/web
RUN pnpm install
RUN pnpm release

# -------------------------
# Build backend
# -------------------------
# Step into the directory where go.mod lives
WORKDIR /src/app/memos
RUN go mod download

# Build the binary and save it to a predictable location (/memos-bin)
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos-bin .


# =========================
# Runtime stage
# =========================
FROM alpine:latest

# Install runtime libraries
RUN apk add --no-cache tzdata sqlite-libs
ENV TZ="UTC"

WORKDIR /usr/local/memos

# Copy the binary from the first stage's specific output path
COPY --from=0 /memos-bin /usr/local/memos/memos

# Setup data directory
RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

# Configuration
EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230
ENV MEMOS_DATA=/var/opt/memos

# Run the binary
ENTRYPOINT ["/usr/local/memos/memos"]