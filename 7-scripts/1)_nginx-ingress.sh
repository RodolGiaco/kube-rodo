#!/bin/bash
#Crea el cluster
kind delete cluster --name=rodo
kind create cluster --name=rodo

#Instala ingress-nginx cotroller mediante helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx

#Aplica todos los manifiestos correspondientes
kubectl apply -f deploy/
kubectl apply -f services/
kubectl apply -f ingress-controller/nginx/svc-np.yaml
#Wait until is ready
sleep 100s
kubectl apply -f ingress/ingress.yaml
kubectl annotate ingress ingress kubernetes.io/ingress.class=nginx

#Mapear url con ip del nodo
#sudo nano /etc/hosts
kubectl get node -o wide

