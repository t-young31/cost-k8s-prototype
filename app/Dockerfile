FROM golang:1.20.7-alpine

WORKDIR /app
RUN unset GOPATH

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    go build -v -o main . && \
    chmod +x main

ENV PORT="8080"
ENV GIN_MODE="release"

CMD ["/app/main"]
