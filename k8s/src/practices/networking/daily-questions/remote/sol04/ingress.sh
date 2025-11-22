k create ingress color-ingress --class=nginx --rule=red.example.com/*=red-svc:5678 --rule=blue.example.com/*=blue-svc:5678 --dry-run=client -o yaml | k apply -f -
