# =========================
# Build stage
# =========================
FROM golang:1.23-alpine

WORKDIR /build

# Build deps (CGO + SQLite + frontend)
RUN apk add --no-cache \
    nodejs \
    npm \
    git \
    bash \
    build-base \
    sqlite-dev

# pnpm
RUN npm install -g pnpm

# COPY CONTEXT
# Build context = app/memos
# So this copies go.mod, main.go, web/, scripts/
COPY . .

# -------------------------
# Frontend
# -------------------------
WORKDIR /build/web
RUN pnpm install
RUN pnpm release

# -------------------------
# Backend
# -------------------------
WORKDIR /build

# go.mod EXISTS HERE — this WILL work
RUN go mod download

RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o memos .

# =========================
# Runtime stage
# =========================
FROM alpine:latest

RUN apk add -
