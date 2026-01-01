.PHONY: build run docker-build docker-push clean help

BINARY_NAME=webhook
GO_BUILD_FLAGS=CGO_ENABLED=0 GOOS=linux
DOCKER_IMAGE=webhook
DOCKER_TAG=v3
REGISTRY=vikashraj1825

# Change this to your registry

build:
	$(GO_BUILD_FLAGS) go build -o $(BINARY_NAME) .

run: build
	./$(BINARY_NAME)

docker-build:
	docker build . -t $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_TAG)

docker-push: docker-build
	docker push $(REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_TAG)

clean:
	rm -f $(BINARY_NAME)

help:
	@echo "make build"
	@echo "make run"
	@echo "make docker-build"
	@echo "make docker-push"
	@echo "make clean"