# =========================
# Build stage
# =========================
FROM golang:1.23-alpine

WORKDIR /src

# System deps (CGO + SQLite + frontend)
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    bash \
    build-base \
    sqlite-dev

RUN npm install -g pnpm@9

# Copy entire repo (monorepo)
COPY . .

# -------------------------
# Build frontend
# -------------------------
WORKDIR /src/app/memos/web
RUN pnpm install
RUN pnpm run build

# -------------------------
# Build backend
# -------------------------
WORKDIR /src/app/memos
RUN go mod download

RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos_binary .

# =========================
# Runtime stage
# =========================
FROM alpine:latest

RUN apk add --no-cache tzdata sqlite-libs
ENV TZ=UTC

WORKDIR /usr/local/memos

COPY --from=0 /memos_binary ./memos

RUN mkdir -p /var/opt/memos
VOLUME /var/opt/memos

EXPOSE 5230
ENV MEMOS_MODE=prod
ENV MEMOS_PORT=5230
ENV MEMOS_DATA=/var/opt/memos

ENTRYPOINT ["/usr/local/memos/memos"]
