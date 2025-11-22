FROM alpine:latest

RUN apk add --no-cache \
    curl bind-tools iputils nmap tcpdump iperf3 netcat-openbsd \
    python3 py3-pip py3-flask py3-requests \
    redis postgresql-client mysql-client jq

WORKDIR /app
COPY api.py .
COPY start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]

