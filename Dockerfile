
# FRONTEND BUILD (PNPM)

FROM node:20-alpine AS frontend-builder

RUN corepack enable

WORKDIR /src/app/memos/web

# Copy dependency files
COPY app/memos/web/package.json app/memos/web/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy frontend source
COPY app/memos/web ./

# Build frontend
RUN pnpm build



# BACKEND BUILD (Go)


FROM golang:1.25-alpine AS backend-builder

WORKDIR /src/app/memos

# Required for CGO
RUN apk add --no-cache git build-base

# Copy Go mod files
COPY app/memos/go.mod app/memos/go.sum ./
RUN go mod download

# Single backend copy
COPY app/memos ./

# Copy frontend dist into backend expected path
COPY --from=frontend-builder \
  /src/app/memos/web/dist \
  /src/app/memos/server/router/frontend/dist

# Build Go binary
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos ./cmd/memos


# Multistage build

FROM alpine:3.19

WORKDIR /app

# Runtime deps for CGO
RUN apk add --no-cache ca-certificates tzdata libc6-compat

# Create non-root user
RUN adduser -D appuser

# Copy backend binary
COPY --from=backend-builder /memos /usr/local/bin/memos

# Change ownership to non-root user
RUN chown appuser:appuser /usr/local/bin/memos

# Switch to non-root user
USER appuser

# Expose Memos port
EXPOSE 5230

# Start Memos
ENTRYPOINT ["memos"]
