
# FRONTEND BUILD (PNPM)

FROM node:20-alpine AS frontend-builder

RUN corepack enable

WORKDIR /src/app/memos/web

COPY app/memos/web/package.json app/memos/web/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY app/memos/web ./

RUN pnpm build


# BACKEND BUILD (Go)
FROM golang:1.25-alpine AS backend-builder

WORKDIR /src/app/memos

RUN apk add --no-cache git build-base

COPY app/memos/go.mod app/memos/go.sum ./
RUN go mod download

COPY app/memos ./

COPY --from=frontend-builder \
  /src/app/memos/web/dist \
  /src/app/memos/server/router/frontend/dist

RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /memos ./cmd/memos


# Multistage Build + Non-Root User

FROM alpine:3.19

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata libc6-compat \
    && addgroup -S app \
    && adduser -S app -G app \
    && mkdir -p /app/data \
    && chown -R app:app /app

COPY --from=backend-builder --chown=app:app /memos /usr/local/bin/memos

USER app

EXPOSE 8081

ENTRYPOINT ["memos"]

