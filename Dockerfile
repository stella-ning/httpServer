FROM golang:1.17 AS build
WORKDIR /httpserver/
COPY . .
ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct
RUN GOOS=linux go build -installsuffix cgo -o httpserver main.go

FROM busybox
COPY --from=build /httpserver/httpserver /httpserver/httpserver
EXPOSE 8090
ENV ENV local
WORKDIR /httpserver/
ENTRYPOINT ["./httpserver"]

FROM golang:1.17 AS builder

ENV GO111MODULE=off \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /build
COPY . .
RUN go build -o httpserver .

FROM scratch
COPY --from=builder /build/httpserver /
EXPOSE 8080
ENTRYPOINT ["/httpserver"]