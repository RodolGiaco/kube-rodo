#!/bin/bash

#Ingress controller
printf "\n\e[92mingress-traefik-controller pod ready!!!\e[0m\n"

#crear namespace beta
kubectl create namespace beta

# Install CRD for Traefik:
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.11/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

# Install RBAC for Traefik:
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.11/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml

#Install traefik
#helm repo add traefik https://helm.traefik.io/traefik
#helm repo update
#helm install traefik traefik/traefik --values traefik/values.yaml --namespace beta
kubectl apply -f ingress-controller/traefik/deploy-gke.yaml --namespace beta
kubectl apply -f ingress-controller/traefik/svc-lb.yaml --namespace beta

#Ingressroot
#kubectl apply -f ingress-controller/traefik/middleware.yaml --namespace beta
kubectl apply -f ingress/ingressroute-tcp.yaml --namespace beta
kubectl apply -f ingress-controller/traefik/tlsoption.yaml

#kubectl apply -f traefik/ingressroute-http.yaml --namespace beta

