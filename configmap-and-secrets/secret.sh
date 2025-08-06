kubectl create secret generic 
  <secret-name> --from-literal=<key>=<value>

kubectl create secret generic app-secret --from-literal=DB_HOST=mysql
