FROM golang:1.18 AS build

WORKDIR /builder

COPY go.mod go.sum ./
RUN go mod download

COPY . ./

# Skaffold passes in debug-oriented compiler flags
ARG SKAFFOLD_GO_GCFLAGS
RUN echo "Go gcflags: ${SKAFFOLD_GO_GCFLAGS}"
RUN go build -gcflags="${SKAFFOLD_GO_GCFLAGS}" -mod=readonly -v -o /app

# Create separate deployment image
FROM gcr.io/distroless/base

ENV GOTRACEBACK=single

# Copy template & assets
WORKDIR /dir
COPY --from=build /app ./app

ENTRYPOINT ["./app"]
