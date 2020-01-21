# Certificate management

Certificate management on both staging and production is done using [cert-manager](https://cert-manager.io) v0.12

Production cluster installation was done using Helm2.
Staging cluster installation... I don't remember if I used Helm3 or manifest install.

## Installation instructions:

Copied from [cert-manager.io](https://cert-manager.io/docs/installation/) for v0.12.

See the content at [this link](https://github.com/cert-manager/website/blob/release-0.12/content/en/docs/installation/kubernetes.md)

### Install with manifests

```shell
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
```

On GKE, also run:

```shell
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(gcloud config get-value core/account)
```

### Helm 2 install

```shell
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  --name cert-manager \
  --namespace cert-manager \
  --version v0.12.0 \
  jetstack/cert-manager
```

## Verifying the installation

```shell
kubectl get pods --namespace cert-manager
```

## Uninstall

### Uninstall with manifests

```shell
kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
```

### Uninstall with Helm 2


```shell
helm delete cert-manager --purge

kubectl delete namespace cert-manager

kubectl delete -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml
```