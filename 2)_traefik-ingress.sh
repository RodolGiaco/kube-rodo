#!/bin/bash
#Crea el cluster
kind delete cluster --name=rodo
kind create cluster --name=rodo

# Install CRD for Traefik:
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.11/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

# Install RBAC for Traefik:
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.11/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml

# Install traefik
kubectl apply -f ingress-controller/traefik/deploy.yaml

#Aplica todos los manifiestos correspondientes
kubectl apply -f deploy/
kubectl apply -f services/
kubectl apply -f ingress-controller/traefik/middleware.yaml
kubectl apply -f ingress-controller/traefik/svc-np.yaml
sleep 100
kubectl apply -f ingress/ingress.yaml
kubectl annotate ingress ingress kubernetes.io/ingress.class=traefik

#Mapear url con ip del nodo
#sudo nano /etc/hosts
kubectl get node -o wide