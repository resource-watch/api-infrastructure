# Resource Watch API - Cluster setup

To setup the cluster cloud resources, use the following command:

```shell script
cd ./terraform
terraform init
terraform plan
CLOUDFLARE_API_KEY=<cloudflare api key> CLOUDFLARE_EMAIL=<cloudflare api key> terraform apply  -var-file=vars/core-dev.tfvarsemail
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
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::843801476059:role/eks-node-group-admin
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes


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

The main resource you'll want to access at this stage is the bastion host. To do so, use ssh:

```shell script
ssh ubuntu@<bastion_hostname value from above>
```

Once on the bastion host, you'll need to configure access to the cluster, otherwise you'll get the following error message when trying to access the cluster:

```shell script
ubuntu@dev-bastion:~$ kubectl get pods
Unable to locate credentials. You can configure credentials by running "aws configure".
Unable to locate credentials. You can configure credentials by running "aws configure".
Unable to locate credentials. You can configure credentials by running "aws configure".
Unable to locate credentials. You can configure credentials by running "aws configure".
Unable to locate credentials. You can configure credentials by running "aws configure".
Unable to connect to the server: getting credentials: exec: exit status 255
```

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