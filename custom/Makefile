# Variables
DOCKER_USERNAME = vikashraj1825
IMAGE_NAME = nginx-curl
TAG = latest
FULL_IMAGE_NAME = $(DOCKER_USERNAME)/$(IMAGE_NAME):$(TAG)

# Default target
.PHONY: all
all: build

# Build the Docker image
.PHONY: build
build:
	@echo "Building $(FULL_IMAGE_NAME)..."
	docker build -t $(FULL_IMAGE_NAME) .

# Push the Docker image to Docker Hub
.PHONY: push
push:
	@echo "Pushing $(FULL_IMAGE_NAME) to Docker Hub..."
	docker push $(FULL_IMAGE_NAME)

# Run the container locally for testing
.PHONY: run
run:
	@echo "Running container locally..."
	docker run -d --name nginx-curl-test -p 8080:80 $(FULL_IMAGE_NAME)

# Test if curl is working inside the container
.PHONY: test
test:
	@echo "Testing if curl is available in the container..."
	docker run --rm $(FULL_IMAGE_NAME) curl --version
	@echo "Testing nginx is running..."
	docker run --rm -d --name test-nginx $(FULL_IMAGE_NAME) && \
	sleep 2 && \
	docker exec test-nginx curl -f http://localhost/ && \
	docker stop test-nginx

# Clean up local containers and images
.PHONY: clean
clean:
	@echo "Cleaning up..."
	docker stop nginx-curl-test 2>/dev/null || true
	docker rm nginx-curl-test 2>/dev/null || true
	docker rmi $(FULL_IMAGE_NAME) 2>/dev/null || true

# Login to Docker Hub
.PHONY: login
login:
	@echo "Logging in to Docker Hub..."
	docker login -u $(DOCKER_USERNAME)

# Build and push in one command
.PHONY: release
release: build push

# Show image information
.PHONY: info
info:
	@echo "Image: $(FULL_IMAGE_NAME)"
	@echo "Size: $$(docker images $(FULL_IMAGE_NAME) --format "table {{.Size}}" | tail -n1)"

# Help message
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make build     - Build the Docker image"
	@echo "  make push      - Push the image to Docker Hub"
	@echo "  make release   - Build and push the image"
	@echo "  make run       - Run the container locally"
	@echo "  make test      - Test the image functionality"
	@echo "  make clean     - Clean up local resources"
	@echo "  make login     - Login to Docker Hub"
	@echo "  make info      - Show image information"
	@echo "  make help      - Show this help message"
