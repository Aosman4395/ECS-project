
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


# Multistage build

FROM alpine:3.19

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata libc6-compat

COPY --from=backend-builder /memos /usr/local/bin/memos

RUN adduser -D appuser
RUN chown appuser:appuser /usr/local/bin/memos
USER appuser

EXPOSE 5230

ENTRYPOINT ["memos"]
