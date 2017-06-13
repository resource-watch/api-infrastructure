#  Devops

This repo groups the relevant information about the WRI-API Ecosystem in terms of Infrastructure, Deployment and Provisioning

## Cloud Providers

### AWS

### Digital Ocean

### Google Cloud Platform

## Architecture

## Microservices + API Gateway Pattern

## Current approach using Docker Swarm

## From Docker Swarm to Kubernetes

## Kubernetes on "Bare Metal" (Next Generation Staging Environment)

In this section we are going to see how to deploy a production-ready Kubernetes cluster on "Bare Metal".

### Creating the Instances.

To create a Kuberentes Cluster on VM instances you need to do the following:

1. Be sure that you already have at least 3 VM instances (from now, Nodes)
2. Enable a private network between them. If you are using Digital Ocean Droplets, you can do it when creating the instances. This should be
enabled by default on using AWS EC2 or Google Compute Engine Instances.

### Creating the Cluster with Kubeadm

Select the Kube Master and connect to it via ssh.

```bash
ssh root@<ip>
```

1. Install kubectl in the master

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
```

2. Install kubelet and kubeadm

```bash
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
# Install docker if you don't have it already.
apt-get install -y docker-engine
apt-get install -y kubelet kubeadm kubernetes-cni
```

**Once kubectl, kubelet and kubeadm are properly installed in the master, connect to the other nodes and
do the same. (We will see how to create a custom image to make this step much easier).**

3. Initializing the master

```bash
kubeadm init
```

4. Set the KUBECONFIG variable to start using your cluster:

```bash
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf
```

Set this variable permanently modifying the profile file of the user:

```bash
sudo vim ~/.profile
```

Add the following content to this file:

`KUBECONFIG="/root/admin.conf"; export KUBECONFIG`


### Setup the Pod Network (Calico - Kubeadm Hosted Install)

For Kubeadm 1.6 with Kubernetes 1.6.x:

```bash
kubectl apply -f http://docs.projectcalico.org/v2.2/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
```

### Joining the Nodes

Connect to each node via ssh and do the following to join the nodes to the Cluster

```bash
kubeadm join --token <token> <master-ip>:<master-port>
```

You can see the token just using the command `kubeadm token list` logged in the master.

### Check

You can now check if everything was fine doing:

`kubectl cluster-info`
`kubectl get nodes`

### API-GATEWAY (CONTROL-TOWER)

The Microservices will be registered through the API Gateway so we only need to expose the Api Gateway Deployment.
To deploy the Gateway in the cluster follow the next steps:

1. Create the Deployment. `kubectl apply -f control-tower-deployment.yaml`
2. Expose it with a NodePort type Service (with a static nodeport value). `kubectl apply -f control-tower-service-staging.yaml`

**Important!**

It is quite important to understand what we've just done.

Our microservices will be registered in the Gateway and they won't be exposed to the internet.
The Gateway has in this case 3 replicas of the Pod. So basically, when we create the service that exposes this Deployment
we are proxying the resulting IP:PORT of each POD to a common IP in our internal network.

If we are into the network the microservices are available in different ways:

1. Pods endpoints: Internal-POD-IP:Container-Port
2. Internal Kube Network Service IP: Service-IP:Service-Port
3. Private Node IP (because of NodePort Service): Private-Node-IP:Node-Port

In this case and because of the lack of the LoadBalancer service in "Bare Metal" we need to proxypass the external and
static public IP to the Private Node IPs where the gateway service is exposing.

To do that, we just need to install Nginx in the KubeMaster and do a basic configuration:

To make this works, we needed to set a static NodePort (in this case 31000) to be pointing at it.

```
upstream control-tower {
	least_conn;

	server <privateIpNodeOne>:31000 max_fails=0 fail_timeout=0;
    server <privateIpNodeTwo>:31000 max_fails=0 fail_timeout=0;
    server <privateIpNodeThree>:31000 max_fails=0 fail_timeout=0;   
}

server {
	server_name <externalIP>;
       	listen 80;

	location / {
        proxy_pass http://control-tower;
	}
}    
```

What about this? https://github.com/kubernetes/contrib/tree/master/service-loadbalancer

## Kubernetes on GKE (Next Generation Production Environment)

In progress...

### GCLOUD SDK

### Create GKE Cluster

`gcloud container clusters create <clusterName>`

### Deploying the Gateway

1. Create the Deployment. `kubectl apply -f control-tower-deployment.yaml`
2. Expose it with a NodePort type Service (mapping to 80). `kubectl apply -f control-tower-service-production.yaml`

### Reserve a static IP

`gcloud compute addresses create <ipName> --global`

### Create an Ingress resource

`kubectl apply -f gateway-ingress.yaml`

Now we have the pods exposing in the pod endpoints in its own containerPorts. The service maps that to its own
service IP and port. And with the ingress resource we enable the external traffic through the static external IP
to the gateway service. In this case we do not need to worry about balancing between node ips.

### Custom Health Checks

Creating the readinessProbe:

```
readinessProbe:
# an http probe
  httpGet:
    path: /healthz
    port: 9000
    scheme: HTTP
```

## Helm

### Install

```bash
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

### RBAC

## Containerizing the Databases

### Kubernetes Entities: ReplicaSet + Persisent Volume + Persistent Volume Claim

### MongoDB

### ElasticSearch

## CI/CD

### Jenkins

https://docs.google.com/document/d/1Ks0l-n-6korqVjLMMMV7NZrlGFPG-q_t2IEYrS5ZWD8/edit

### Independent Container Builder

https://cloud.google.com/container-builder/docs/

### Private or Public Container Registry

## Provisioning

### Terraform

### Spinnaker

## Next steps

### GRPC Support

Check this out -> https://github.com/Vizzuality/python-skeleton-grpc

### Istio?

#### Installing Istio

1. Get istio: `curl -L https://git.io/getIstio | sh -`

2. Add the istioctl client to your PATH `export PATH=$PWD/bin:$PATH`

3. Run the following command to determine if your cluster has RBAC `kubectl api-versions | grep rbac`

4. It is highly recommended to create a clusterrolebinding `kubectl create clusterrolebinding myname-cluster-admin-binding --clusterrole=cluster-admin --user=myname@example.org`

5. Install the istio-rbac config: `kubectl apply -f install/kubernetes/istio-rbac-alpha.yaml`

6. Install Istio: `kubectl apply -f install/kubernetes/istio.yaml`

Optional:

Enabling Metrics:

```bash
kubectl apply -f install/kubernetes/addons/prometheus.yaml
kubectl apply -f install/kubernetes/addons/grafana.yaml
kubectl apply -f install/kubernetes/addons/servicegraph.yaml
```

#### Enabling Ingress Traffic

1. Start the httpbin sample: `kubectl apply -f <(istioctl kube-inject -f samples/apps/httpbin/httpbin.yaml)`

2. Create the Ingress Resource for the httpbin service:

```bash
cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: simple-ingress
  annotations:
    kubernetes.io/ingress.class: istio
spec:
  rules:
  - http:
      paths:
      - path: /headers
        backend:
          serviceName: httpbin
          servicePort: 8000
      - path: /delay/.*
        backend:
          serviceName: httpbin
          servicePort: 8000
EOF
```

3. Determine the ingress URL:

Because this cluster is running on Digital Ocean, there is no LoadBalancer service available.

Get the ingress-istio NodeIP:

`kubectl get po -l istio=ingress -o jsonpath='{.items[0].status.hostIP}'`

Get the Port:

`kubectl get svc istio-ingress`

Go to the URL: http://<IP>:<PORT>/headers
