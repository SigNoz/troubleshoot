FROM golang:1.17-stretch AS builder

# Define docker arguments with default values
ARG GOOS=linux
ARG GOARCH=amd64

# Set environment variables
ENV GOPATH=/go
ENV GOOS=${GOOS}
ENV GOARCH=${GOARCH}
ENV CGO_ENABLED=0

# Set work directory and copy source code
WORKDIR ${GOPATH}/src/github.com/signoz/troubleshoot
COPY . .

# Fetch dependencies.
# Using go get.
RUN go get -d -v

RUN go mod download -x

# Add the sources and proceed with build
ADD . .
RUN go build -o /go/bin/troubleshoot

# use a scratch to run binary
FROM scratch

# Add Maintainer Info
LABEL maintainer="signoz"

# copy the binary from builder
COPY --from=builder /go/bin/troubleshoot /

# run the binary
ENTRYPOINT ["/troubleshoot"]
