FROM golang:1.20.7-alpine

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .

CMD ["sh"]
