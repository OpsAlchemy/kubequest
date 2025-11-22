APP_NAME = api-demo
VERSION = 1.0.0
DOCKER_USERNAME = vikashraj1825
DOCKER_IMAGE = $(DOCKER_USERNAME)/$(APP_NAME):$(VERSION)
K8S_NAMESPACE = playground
DEPLOYMENT_FILE = deployment.yaml
INGRESS_FILE = ingress.yaml
GATEWAY_FILE = gateway.yaml
ROUTE_FILE = route.yaml

.PHONY: help build push run stop clean deploy delete logs status test

help:
	@echo "build    - Build Docker image"
	@echo "run      - Run container locally"
	@echo "stop     - Stop local container"
	@echo "push     - Push image to Docker Hub"
	@echo "deploy   - Deploy to Kubernetes with Ingress"
	@echo "delete   - Delete Kubernetes deployment"
	@echo "logs     - View container logs"
	@echo "clean    - Remove local container and image"
	@echo "expose   - Expose the application with gateway"

build:
	docker build -t $(DOCKER_IMAGE) .

run:
	docker run -d -p 5000:5000 --name $(APP_NAME) $(DOCKER_IMAGE)

stop:
	docker stop $(APP_NAME) || true
	docker rm $(APP_NAME) || true

push: build
	docker push $(DOCKER_IMAGE)

deploy: 
	kubectl apply -f $(DEPLOYMENT_FILE)

delete:
	kubectl delete -f $(DEPLOYMENT_FILE) --ignore-not-found

logs:
	kubectl logs -l app=$(APP_NAME) --namespace=$(K8S_NAMESPACE) --tail=50 -f

status:
	kubectl get pods,svc,ingress -l app=$(APP_NAME) --namespace=$(K8S_NAMESPACE)

clean: stop
	docker rmi $(DOCKER_IMAGE) || true
expose:
	kubectl apply -f $(GATEWAY_FILE)
	kubectl apply -f $(ROUTE_FILE)
