openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-out tls.crt -keyout tls.key -subj "/CN=app.example.com"

kubectl create secret tls app-tls --cert=tls.crt --key=tls.key --dry-run=client -o yaml | kubectl apply -f -
