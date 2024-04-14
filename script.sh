#!/bin/bash
kind delete cluster --name=rodo
kind create cluster --name=rodo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx
# Define una función para aplicar los manifiestos en una carpeta
apply_manifests() {
    local folder="$1"
    local manifests=($(find $folder -type f -name "*.yaml"))

    for manifest in "${manifests[@]}"
    do
        echo "Aplicando $manifest..."
        kubectl apply -f $manifest
        echo ""
    done
}

# Aplicar los manifiestos en la carpeta 'deploy'
apply_manifests "deploy"

# Aplicar los manifiestos en la carpeta 'ingress'
apply_manifests "nginx"

sleep 200
# Aplicar los manifiestos en la carpeta 'ingress'
apply_manifests "ingress"
