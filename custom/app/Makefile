# Makefile for NetKit Docker operations
IMAGE_NAME = vikashraj1825/netkit
TAG = latest
FULL_IMAGE = $(IMAGE_NAME):$(TAG)

.PHONY: help build push run clean

help:
	@echo "Available commands:"
	@echo "  build    - Build Docker image"
	@echo "  push     - Push image to registry"
	@echo "  run      - Run container locally"
	@echo "  clean    - Remove local image"

build:
	docker build -t $(FULL_IMAGE) .

push: build
	docker push $(FULL_IMAGE)

run: build
	docker run -it --rm \
		-e TEXT="Local NetKit" \
		-e PORT=8080 \
		-p 8080:8080 \
		$(FULL_IMAGE)

clean:
	docker rmi $(FULL_IMAGE) || true
