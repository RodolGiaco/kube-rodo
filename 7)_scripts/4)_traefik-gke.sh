#!/bin/bash

#Ingress controller
printf "\n\e[92mingress-traefik-controller pod ready!!!\e[0m\n"

#crear namespace beta
kubectl create namespace beta

# Install CRD for Traefik:
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.0/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

# Install RBAC for Traefik:
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.0/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml
kubectl apply -f traefik/




