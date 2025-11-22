# Stage 1: get CoreDNS binary
FROM coredns/coredns:latest as coredns_src

# Stage 2: put it inside Alpine
FROM alpine:3.18
RUN apk add --no-cache bash bind-tools

# Copy coredns binary
COPY --from=coredns_src /coredns /coredns

# Default Corefile location (if you want to mount one)
WORKDIR /etc/coredns

EXPOSE 53 53/udp

ENTRYPOINT ["/coredns"]

