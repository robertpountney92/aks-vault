# Configure Vault Certificate Authority

    terraform init
    terraform apply -auto-approve

## Issue new certificate

    vault write pki_int/issue/example-dot-com common_name="test.example.com" ttl="24h"
    