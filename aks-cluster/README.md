# Provision AKS Cluster
Create AKS cluster using Terraform

    terraform init
    terraform apply -auto-approve

When promted enter a password of your choice.

## Configure kubectl

To configure kubetcl run the following command:

```shell
$ az aks get-credentials --resource-group $(terraform output resource_group_name) --name $(terraform output kubernetes_cluster_name)
```

## Configure Kubernetes Dashboard

To use the Kubernetes dashboard, we need to create a `ClusterRoleBinding`. This
gives the `cluster-admin` permission to access the `kubernetes-dashboard`.

```shell
$ kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard  --user=clusterUser
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
```

Finally, to access the Kubernetes dashboard, run the following command:

```shell
$ az aks browse --resource-group light-eagle-rg --name light-eagle-aks
Merged "light-eagle-aks" as current context in /var/folders/s6/m22_k3p11z104k2vx1jkqr2c0000gp/T/tmpcrh3pjs_
Proxy running on http://127.0.0.1:8001/
Press CTRL+C to close the tunnel...
```

 You should be able to access the Kubernetes dashboard at [http://127.0.0.1:8001/](http://127.0.0.1:8001/).
