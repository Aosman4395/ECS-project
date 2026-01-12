########################################
# 1️⃣ FRONTEND BUILD (PNPM)
########################################
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


########################################
# 2️⃣ BACKEND BUILD (Go)
########################################
FROM golang:1.25-alpine AS backend-builder

WORKDIR /src/app/memos

# Required for CGO
RUN apk add --no-cache git build-base

# Copy Go mod files
COPY app/memos/go.mod app/memos/go.sum ./
RUN go mod download

# Explicit backend copies (no guessing)
COPY app/memos/cmd ./cmd
COPY app/memos/server ./server
COPY app/memos/web ./web

# Prove cmd/memos exists inside Docker
RUN echo "==== DEBUG: listing cmd directory ====" && ls -R cmd

# Copy frontend dist into backend expected path
COPY --from=frontend-builder \
  /src/app/memos/web/dist \
  /src/app/memos/server/router/frontend/dist

# Prove frontend dist exists
RUN echo "==== DEBUG: listing frontend dist ====" && ls -R server/router/frontend

# Build Go binary
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos ./cmd/memos


########################################
# 3️⃣ FINAL RUNTIME IMAGE
########################################
FROM alpine:3.19

WORKDIR /app

# Runtime deps for CGO
RUN apk add --no-cache ca-certificates tzdata libc6-compat

# Copy backend binary
COPY --from=backend-builder /memos /usr/local/bin/memos

# Expose Memos port
EXPOSE 5230

# Start Memos
ENTRYPOINT ["memos"]
