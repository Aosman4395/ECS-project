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

# Copy the entire ECS-project into /build
COPY . .

# -------------------------
# Build frontend
# -------------------------
# Based on your find command, web is likely here:
WORKDIR /build/app/memos/web
RUN pnpm install
RUN pnpm release

# -------------------------
# Build backend
# -------------------------
# Move to where go.mod actually lives
WORKDIR /build/app/memos
RUN go mod download

# Build the binary and output it to /build/memos
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /build/memos .


# =========================
# Runtime stage
# =========================
FROM alpine:latest

# Install runtime dependencies for SQLite
RUN apk add --no-cache tzdata sqlite-libs
ENV TZ="UTC"

WORKDIR /usr/local/memos

# Copy the binary from the build stage root
COPY --from=0 /build/memos /usr/local/memos/memos

# Copy the entrypoint script (Adjusting path based on your nesting)
COPY app/memos/scripts/entrypoint.sh /usr/local/memos/
RUN chmod +x /usr/local/memos/entrypoint.sh

# Data directory
RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230

ENTRYPOINT ["./entrypoint.sh", "./memos"]