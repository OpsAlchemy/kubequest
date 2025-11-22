rm -rf tls.key tls.crt

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-out tls.crt -keyout tls.key -subj "/CN=secure.example.com"

kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key --dry-run=client -o yaml | kubectl apply -f -

kubectl create deploy nginx --image nginx --dry-run=client -o yaml | kubectl apply -f -

kubectl rollout status deploy nginx --timeout=120s

kubectl expose deploy nginx --name nginx-svc --port 80 --dry-run=client -o yaml | kubectl apply -f -

kubectl create ingress secure-ingress --class=nginx --rule="secure.example.com/*=nginx-svc:80,tls=tls-secret" --dry-run=client -o yaml | kubectl apply -f - 
