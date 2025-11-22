# stop & remove any old container
docker rm -f zealous_newton 2>/dev/null || true

# run using absolute path to current Corefile (safer than relying on ~)
docker run -d --name zealous_newton \
  -p 1053:53/udp -p 1053:53/tcp \
  -v "$(pwd)/Corefile":/Corefile:ro \
  -v "$(pwd)":/etc/coredns:ro \
  coredns/demo

