# Deploy Vault via Helm using Terraform

    terraform init
    terraform apply -auto-approve

## Vault Auto Unseal

Initialize Vault on pod 0

    kubectl exec -it vault-0 -n vault -- vault operator init -recovery-shares=1 -recovery-threshold=1 | grep "Initial Root Token:" | awk 'NR==1 {print $NF}'

    export VAULT_TOKEN=<root_token> # From command above

Any other pod in the cluster run the following to add the pod to the Raft storage backend

    kubectl exec -it -n vault vault-X -- vault operator raft join "http://vault-0.vault-internal:8200"


## Connect to Vault Cluster

Connect to Vault cluster from local machine

    export VAULT_ADDR=$(terraform output vault_lb_endpoint)

Test connection

    vault secrets list