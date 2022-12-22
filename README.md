# Resource Watch API - Cluster setup

**Important**: this repo uses [git lfs](https://git-lfs.github.com/).

For a description of the setup, see the infrastructure [section](https://resource-watch.github.io/doc-api/developer.html#infrastructure-configuration) of the developer documentation.

## Setting up the AWS resources

To setup the cluster cloud resources, use the following command:

```shell script
cd ./terraform
export CLOUDFLARE_API_KEY=<cloudflare api key> CLOUDFLARE_EMAIL=<cloudflare account email address>
terraform init -backend-config=vars/backend-<env>.tfvars
terraform plan -var-file=vars/terraform-<env>.tfvars
```

Set `<env>` to dev, staging or production - the environment that you're deploying to. Each environment has separate AWS account isolating resources including bastion server, jenkins server, EKS kubernetes cluster, etc.

If configuring `dev` environment resources and you'll be modifying kubernetes infrastructure, you may want to bring the cluster up from hibernation by setting `hibernate = false` in `./vars/terraform-dev.tfvars`. Finally apply your changes:

```shell script
terraform apply -var-file=vars/terraform-<env>.tfvars
```

On the last step, you'll be asked to confirm your action, as this is the step that "does stuff".
Deploying the whole infrastructure may take about 15 minutes, so grad a drink.

Once it's done,you'll see some output like this:

```shell script
Outputs:

account_id = <your aws account id>
bastion_hostname = ec2-18-234-188-9.compute-1.amazonaws.com
environment = dev
jenkins_hostname = ec2-34-203-238-24.compute-1.amazonaws.com
kube_configmap = apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::843801476059:role/eks_manager
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:masters
    - rolearn: arn:aws:iam::843801476059:role/eks-node-group-admin
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes


kubectl_config = # see also: https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html

apiVersion: v1
clusters:
- cluster:
    server: https://<random string>.gr7.us-east-1.eks.amazonaws.com
    certificate-authority-data: <random base64 string>
  name: core-k8s-cluster-dev
contexts:
- context:
    cluster: core-k8s-cluster-dev
    user: aws-rw-dev
  name: aws-rw-dev
kind: Config
preferences: {}
current-context: aws-rw-dev
users:
- name: aws-rw-dev
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "core-k8s-cluster-dev"
        # - "-r"
        # - "<role-arn>"
      # env:
        # - name: AWS_PROFILE
        #   value: "<aws-profile>"

nat_gateway_ips = [
  [
    "3.211.237.248",
    "3.212.157.210",
    "34.235.74.8",
    "3.219.120.245",
    "34.195.181.97",
    "3.233.11.188",
  ],
]
```

At this point, most of your resources should already be provisioned, and some things will be wrapping up (for example, EC2 `userdata` scripts).

## Accessing the Kubernetes cluster

The main resource you'll want to access at this stage is the bastion host. To do so, use ssh:

```shell script
ssh ubuntu@<bastion_hostname value from above>
```

Assuming your public key was sent to the bastion host during the setup process, you should have access. Next, you'll want to configure access to the cluster. As the cluster is only available on the private VPC, you'll need to do so through the bastion host - hence the need to verify you have access to the bastion host.

From here, there are multiple ways to proceed.

### SSH tunnel

Perhaps the most practical way to connect to the cluster is by creating an SSH tunnel that connects a local port to the cluster's API port, through the bastion. For this to work, a few things are needed:

- Copy the `kubectl_config` settings from above into your local `~/.kube/config`
- Modify the `server: https://<random string>.gr7.us-east-1.eks.amazonaws.com` line by adding `:4433` at the end, so it looks like this: `server: https://<random string>.gr7.us-east-1.eks.amazonaws.com:4433` (you can pick a different port if you want)
- Modify your local `/etc/hosts` to include the following line: `127.0.0.1 <eks api endpoint url>`

```shell script
ssh -N -L 4433:<eks api endpoint url>:443 <bastion user>@<bastion hostname>

```

### Access from bastion

Another way to connect to the cluster is doing so from a bash shell running on the bastion. However, this will require the actual bastion host to have access to the cluster. That is done using `kubectl` config - which is automatically taken care of during the cluster setup phase - and through IAM roles, which you need to configure using these steps.

**Disclaimer**: the next steps will see you add AWS credentials to the AWS CLI in the bastion host. This is a VERY BAD IDEA, and it's done here as a temporary workaround. Be sure to remove the `~/.aws/credentials` file once you're done.

Run `aws configure` and set the `AWS Access Key ID` and `AWS Secret Access Key` of the AWS user who created the cluster. If this was done correctly, you should see the following output now:

```shell script
ubuntu@dev-bastion:~$ kubectl get pods
No resources found in default namespace.
```

Now that you have access to the cluster, you need to configure it to allow access based on an AWS IAM role, and not just to the user who created the cluster. To do so, you need to edit a Kubernetes configmap:

```shell script
KUBE_EDITOR="nano" kubectl edit configmap aws-auth -n kube-system
```

You'll need to replace the `data` section in this document with the one from the `terraform apply` command `kube_configmap`. Saving your changes and exiting the editor will push the new configuration to the cluster.

Next, delete your local `~/.aws/credentials` file - this will ensure that no authentication information remains inside the cluster, and that all access management is done using IAM Roles, which is the recommended way.

You should now have access to the cluster from the bastion host.

## Kubernetes base configuration

With access configured as above, and with the SSH tunnel active, you can now proceed to configuring the Kubernetes cluster itself.

### Namespaces

At this point you should have the necessary cloud resources provisioned and access to them configured. The next steps will provision the logical resources (databases and other dependencies) on top of which the API will operate.

The first step will be to create the necessary [Kubernetes namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) using the following command from inside the `terraform-k8s-infrastructure` folder:

```shell script
terraform apply -var-file=vars/terraform-<your environment>.tfvars -target=module.k8s_namespaces
```

### Secrets

Once the namespaces are created, you should apply all the necessary [Kubernetes secrets](https://kubernetes.io/docs/concepts/configuration/secret/), as some of them will be needed by the components we'll provision in the next step. Refer to the secrets repository for more details.

### Kubernetes configuration

After the necessary secrets are created, you can deploy the rest of the infrastructure using the following command:

```shell script
terraform apply -var-file=vars/terraform-<your environment>.tfvars
```

The command above will provision most of the resources needed by the API. However, some resources will still require manual deployment after this - check the `k8s-aws` folder and its sub-folders for more details.
