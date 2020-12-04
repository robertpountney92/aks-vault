# Create an HTTPS ingress controller and use your own TLS certificates on Azure Kubernetes Service (AKS)
Add the ingress-nginx repository
    
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

Use Helm to deploy an NGINX ingress controller
    
    helm install nginx-ingress ingress-nginx/ingress-nginx \
        --set controller.replicaCount=2 \
        --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
        --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

Generate TLS certificates using openssl self-signed (or alternatively use Vault as CA, see `vault-ca` dir.)

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -out tls.crt \
        -keyout tls.key \
        -subj "/CN=example.com"

Create Kubernetes secret for the TLS certificate

    kubectl create secret tls aks-ingress-tls \
        --key tls.key \
        --cert tls.crt

Run the two demo applications using `kubectl apply`

    kubectl apply -f aks-helloworld.yaml

Create the ingress resource 

    kubectl apply -f hello-world-ingress.yaml

Test the ingress configuration (self-signed)

    curl -v -k --resolve example.com:443:$(kubectl get services nginx-ingress-ingress-nginx-controller | awk 'NR==2 {print $4}') https://example.com # Trusts any certificates
    curl -v --cacert tls.crt --resolve example.com:443:$(kubectl get services nginx-ingress-ingress-nginx-controller | awk 'NR==2 {print $4}') https://example.com # Trusts on certificate specified in command

## IMPORTANT PLEASE READ

Note: if you are using Vault as CA then you must provide the CA certificates of **both** the intermediate CA (i.e. issuing_ca from `pki_int/issue/example-dot-com` command) and the root CA (see output root_ca from vault-ca directory). You can do this by concatenating the two .pem files into one file, typically referred to as a `tls-ca-bundle.crt`.

So in this case there would be an additional file `tls-ca-bundle.crt`, which is both root and intermediate ca certs concatenated. The command to verify the request would be...

    curl -v --cacert tls-ca-bundle.crt--resolve test.example.com:443:$(kubectl get services nginx-ingress-ingress-nginx-controller | awk 'NR==2 {print $4}') https://test.example.com

Both the root certificate and intermediate certificate must be made available to verify the certificates. They constitute a chain of trust that ensures the authenticity of the certificate owner.