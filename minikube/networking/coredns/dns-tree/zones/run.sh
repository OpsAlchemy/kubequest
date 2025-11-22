docker run --rm -p 1053:53/udp -p 1053:53/tcp \
	-v $(pwd)/:/zones \
	-v $(pwd)/Corefile:/Corefile \
  coredns/demo -conf /Corefile

