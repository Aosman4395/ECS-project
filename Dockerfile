# =========================
# Build stage (frontend + backend together)
# =========================
FROM golang:1.23-alpine

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    bash \
    build-base \
    sqlite-dev

# Install pnpm
RUN npm install -g pnpm

# Copy the entire project into /build
COPY . .

# -------------------------
# Build frontend
# -------------------------
WORKDIR /build/app/memos/web
RUN pnpm install
RUN pnpm release

# -------------------------
# Build backend
# -------------------------
WORKDIR /build/app/memos
RUN go mod download

# Build the binary with CGO enabled for SQLite support
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /build/memos .


# =========================
# Runtime stage
# =========================
FROM alpine:latest

# Install runtime dependencies for SQLite and Timezones
RUN apk add --no-cache tzdata sqlite-libs
ENV TZ="UTC"

WORKDIR /usr/local/memos

# Copy the binary from the build stage root
COPY --from=0 /build/memos /usr/local/memos/memos

# Data directory setup
RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

# Configuration
EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230
ENV MEMOS_DATA=/var/opt/memos

# Execute the binary directly to avoid "entrypoint.sh not found" errors
ENTRYPOINT ["/usr/local/memos/memos"]