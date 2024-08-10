# Build stage
FROM rust:latest AS builder

# Install build dependencies
RUN apk add --no-cache musl-dev

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Build the project
RUN cargo build --release

# Identify and copy only the needed shared libraries
RUN mkdir -p /app/lib && \
    ldd /app/target/release/vproxy | \
    grep "=> /" | \
    awk '{print $3}' | \
    sort -u | \
    xargs -I '{}' cp -v '{}' /app/lib/

# Runtime stage
FROM alpine:3.16

# Copy the built binary from the builder stage
COPY --from=builder /app/target/release/vproxy /bin/vproxy

# Iproute2 and procps are needed for the vproxy to work
RUN apk add --no-cache iproute2 procps
RUN echo "net.ipv6.conf.all.disable_ipv6 = 0" >> /etc/sysctl.conf

# Set the entrypoint
ENTRYPOINT ["/bin/vproxy"]
