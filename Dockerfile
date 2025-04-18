# Stage 1: Build web client
FROM node:20-alpine AS client_builder

ENV NODE_VERSION=20
WORKDIR /app/web/client

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    libc6-compat \
    && rm -rf /var/cache/apk/*

# Switch to Yarn Classic and configure Python
RUN corepack enable && \
    corepack prepare yarn@1.22.19 --activate && \
    yarn config set python /usr/bin/python3

# Copy package files for caching
COPY web/client/package.json web/client/yarn.lock ./

# Install dependencies with retry mechanism
RUN --mount=type=cache,target=/root/.yarn \
    yarn install --frozen-lockfile --network-timeout 100000 || \
    (echo "Retrying yarn install..." && \
    yarn install --frozen-lockfile --network-timeout 100000 --verbose)

# Copy web client source and build
COPY web/client .
RUN yarn build

# Stage 2: Build Go application
FROM golang:alpine AS go_builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git make gcc musl-dev

# Copy Go mod files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code and web client build
COPY . .
COPY --from=client_builder /app/web/client/dist ./web/client/dist

# Build with platform-specific optimizations
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 \
    go build -o phoneinfoga \
    -ldflags="-w -s" .

# Stage 3: Final lightweight image
FROM alpine:latest

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache ca-certificates tzdata && \
    adduser -D -h /app phoneinfoga

# Copy binary and set permissions
COPY --from=go_builder /app/phoneinfoga .
RUN chown -R phoneinfoga:phoneinfoga /app

USER phoneinfoga
EXPOSE 5000

ENTRYPOINT ["/app/phoneinfoga"]
CMD ["serve", "-h", "0.0.0.0", "-p", "5000"]
