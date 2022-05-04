FROM golang:alpine as build
ARG APPLICATION_NAME
WORKDIR /build
COPY cmd cmd/
COPY go.mod .
COPY go.sum .
RUN ls cmd
RUN go build -o app ./cmd/$APPLICATION_NAME/

FROM alpine
COPY --from=build /build/app /app
EXPOSE 80
ENTRYPOINT [ "/app" ]
