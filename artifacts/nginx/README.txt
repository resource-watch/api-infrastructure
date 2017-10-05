# Deploy nginx file
kubectl delete configmap nginx-conf

kubectl create configmap nginx-conf --from-file=default-<env>.conf
