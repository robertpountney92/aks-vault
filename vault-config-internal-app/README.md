# Configure Vault to supply secrets to internal app

    terraform init
    terraform apply -auto-approve

## Deploy Orgchart App


    kubectl apply --filename deployment-orgchart.yml -n vault 

    kubectl exec -n vault $(kubectl get pod -n vault -l app=orgchart -o jsonpath="{.items[0].metadata.name}") --container orgchart -- ls /vault/secrets

output should read... 
```ls: /vault/secrets: No such file or directory```

## Patch Orgchart App with secrets injected via annotations (Vault Agent injector)
No annotations exist within the current deployment. This means that no secrets are present on the orgchart container within the orgchart pod.

The Vault Agent Injector only modifies a deployment if it contains a specific set of annotations. An existing deployment may have its definition patched to include the necessary annotations.

    kubectl patch deployment orgchart --patch "$(cat patch-inject-secrets-as-template.yml)" -n vault

    kubectl exec -n vault $(kubectl get pod -n vault -l app=orgchart -o jsonpath="{.items[0].metadata.name}") --container orgchart -- cat /vault/secrets/database-config.txt