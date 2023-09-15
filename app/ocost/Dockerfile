FROM golang:1.20.7-alpine

# TODO: go binary rather than curl, saving a few MB
RUN apk --no-cache add curl

WORKDIR /app
RUN unset GOPATH

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    go build -v -o main cmd/main.go && \
    chmod +x main

ENV PORT="8080"
ENV GIN_MODE="release"
ENV GROUP_MAP_PATH="/app/group_map.json"
ENV OPENCOST_URL="http://localhost:9003"

HEALTHCHECK --interval=10s --timeout=30s \
  CMD curl --fail "http://0.0.0.0:${PORT}/ping" || exit 1

# CMD ["tail", "-f", "/dev/null"]
CMD ["/app/main"]
