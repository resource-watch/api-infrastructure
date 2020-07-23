# Setting up Jenkins

The setup for the Jenkins machine is included in the Terraform setup. It is advised to copy the configurations from an existing server, in order to save the trouble of having to recreate the configuration from scratch.

## Copying the configuration from an existing Jenkins server

In order to copy the configuration from an existing Jenkins instance to a new one, first, stop both Jenkins instances. Create a zip file with the contents of the Jenkins home directory (by default, `/var/lib/jenkins`) and copy it to the new Jenkins instance. Extract the contents and overwrite the existing content of the Jenkins home directory in the new Jenkins instance. Change the ownership of the Jenkins home dir (`chown -R jenkins:jenkins /var/lib/jenkins`). Lastly, don't forget to restart both Jenkins instances.

For reference, check [this Stack Overflow thread](https://stackoverflow.com/questions/8724939/how-to-move-jenkins-from-one-pc-to-another/37525829#37525829).

## Accessing the Kubernetes cluster from the Jenkins instance

In order to successfully complete Jenkins jobs, the Jenkins instance will require access to the cluster. For this, you need to setup a Kube config file in the root of the Jenkins home directory `/var/lib/jenkins/.kube/config` and there, create a context for the cluster you are trying to access. Don't forget to change the ownership of these files as well, otherwise Jenkins jobs might run into permission issues (`chown -R jenkins:jenkins /var/lib/jenkins/.kube`).

If you run into Kubernetes RBAC issues such as the one below:

```shell
Error from server (Forbidden): deployments.extensions "control-tower" is forbidden: User "system:node:ip-10-0-2-124.ec2.internal" cannot get resource "deployments" in API group "extensions" in the namespace "gateway"
```

In this case, you might need to add a new ClusterRoleBinding to the Jenkins instance user:

```shell
kubectl create clusterrolebinding jenkins --clusterrole=edit --user=system:node:ip-10-0-2-124.ec2.internal
```
