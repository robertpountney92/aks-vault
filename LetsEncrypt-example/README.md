# Create an HTTPS ingress controller and use your own TLS certificates on Azure Kubernetes Service (AKS)
Create a namespace for your ingress resources
    
    kubectl create namespace ingress-basic

Add the ingress-nginx repository
    
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

Use Helm to deploy an NGINX ingress controller
    
    helm install nginx-ingress ingress-nginx/ingress-nginx \
        --namespace ingress-basic \
        --set controller.replicaCount=2 \
        --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
        --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

Configure an FQDN for the ingress controller `EXTERNAL_IP`

    # Public IP address of your ingress controller
    IP=$(kubectl get services nginx-ingress-ingress-nginx-controller --namespace ingress-basic | awk 'NR==2 {print $4}')

    # Name to associate with public IP address
    DNSNAME="rob-aks-ingress"

    # Get the resource-id of the public ip (Note may need to wait a few minutes for this to work)
    PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)

    # Update public ip address with DNS name
    az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME

    # Display the FQDN
    az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv

Label the ingress-basic namespace to disable resource validation
    
    kubectl label namespace ingress-basic cert-manager.io/disable-validation=true

Add the Jetstack Helm repository
    
    helm repo add jetstack https://charts.jetstack.io

Update your local Helm chart repository cache
    
    helm repo update

Install the cert-manager Helm chart
    
    helm install \
        cert-manager \
        --namespace ingress-basic \
        --version v0.16.1 \
        --set installCRDs=true \
        --set nodeSelector."beta\.kubernetes\.io/os"=linux \
        jetstack/cert-manager

Create cluster issuer

    kubectl apply -f cluster-issuer.yaml

Run the two demo applications using `kubectl apply`

    kubectl apply -f aks-helloworld-one.yaml --namespace ingress-basic
    kubectl apply -f aks-helloworld-two.yaml --namespace ingress-basic

Create an ingress route 

    kubectl apply -f hello-world-ingress.yaml --namespace ingress-basic

Verify that the certificate was created successfully by checking READY is True, which may take several minutes.

    kubectl get certificate --namespace ingress-basic
