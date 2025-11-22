docker run --rm \
  --network host \
  -v $(pwd)/:/zones \
  -v $(pwd)/Corefile:/Corefile \
  coredns/demo -conf /Corefile

