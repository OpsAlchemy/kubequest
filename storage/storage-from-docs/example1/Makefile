APP_NAME := log-reader
IMAGE_NAME := vikashraj1825/log-reader
TAG := latest

.PHONY: build docker-build docker-push clean

build:
	GOOS=linux GOARCH=amd64 go build -o $(APP_NAME) main.go 

docker-build:
	docker build -t $(IMAGE_NAME):$(TAG) .

docker-push:
	docker push $(IMAGE_NAME):$(TAG)

clean:
	rm -f $(APP_NAME)
