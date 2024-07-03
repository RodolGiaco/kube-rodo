#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
print_msg() {
  local color=$1
  local msg=$2
  echo -e "${color}${msg}${NC}"
}

# Descomentar para limpieza completa del cluster
 print_msg $RED "Eliminando todos los recursos en el cluster..."
 helm ls --all --all-namespaces -q | xargs -I {} helm uninstall {} --namespace monitoring
 helm ls --all --all-namespaces -q | xargs -I {} helm uninstall {} --namespace beta
 kubectl delete all --all --all-namespaces
 kubectl delete configmaps --all --all-namespaces
 kubectl delete secrets --all --all-namespaces
 kubectl delete pvc --all --all-namespaces
 kubectl delete pv --all
 kubectl delete crd --all
 kubectl delete ingress --all --all-namespaces
 kubectl delete networkpolicies --all --all-namespaces
 kubectl delete roles --all --all-namespaces
 kubectl delete rolebindings --all --all-namespaces
 print_msg $GREEN "Eliminación completada"

 Instalar Traefik
print_msg $BLUE "Instalando Traefik..."
# kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.0/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
# kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v3.0/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml
kubectl create namespace monitoring
kubectl apply -f 3-traefik/1-namespaces.yaml
kubectl apply -f 3-traefik/2-crd.yaml
kubectl apply -f 3-traefik/3-clusterrole.yaml
kubectl apply -f 3-traefik/4-clusterrolebinding.yaml
sleep 10
kubectl apply -f 3-traefik/5-deployment.yaml
sleep 20
kubectl apply -f 3-traefik/6-middleware.yaml
kubectl apply -f 3-traefik/7-svc-lb.yaml
kubectl apply -f 3-traefik/8-ingressroute.yaml
kubectl apply -f 3-traefik/9-ingressclass.yaml
print_msg $GREEN "Implementación de Traefik completada."

# Instalar Prometheus
print_msg $BLUE "Instalando Prometheus..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus-operator prometheus-community/kube-prometheus-stack -n monitoring -f 8-values/1-prometheus-operated.yaml
helm install prometheus prometheus-community/prometheus -n monitoring
# helm install prometheus-adapter prometheus-community/prometheus-adapter --namespace monitoring --set prometheus.url=http://prometheus-operated.monitoring.svc

set -e

NAMESPACE="monitoring"
CONFIGMAP_NAME="prometheus-adapter-config"

# Aplicar yamls adicionales
print_msg $BLUE "Aplicando ConfigMap y ServiceMonitor personalizados..."
kubectl apply -f 8-values/3-prometheus-adapter-cofig.yaml
kubectl apply -f 8-values/4-traefik-servicemonitor.yaml
kubectl apply -f 8-values/5-api-service.yaml


# Instalar o actualizar el prometheus-adapter con Helm usando --set
print_msg $BLUE "Instalando prometheus-adapter con reglas de ClusterRole personalizadas..."
helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter --namespace ${NAMESPACE} \
  --set prometheus.url=http://prometheus-operated.monitoring.svc \
  --set configMapOverride.enabled=true \
  --set configMapOverride.name=${CONFIGMAP_NAME} \
  --set rbac.create=true \
  --set rbac.pspEnabled=false \
  --set rbac.clusterRoleRules[1].apiGroups[0]=external.metrics.k8s.io \
  --set rbac.clusterRoleRules[1].resources[0]=* \
  --set rbac.clusterRoleRules[1].verbs[0]=*
print_msg $GREEN "ConfigMap personalizado y prometheus-adapter aplicados correctamente."
print_msg $GREEN "Implementación de Prometheus completada."

# Función para aplicar una aplicación
apply_app() {
  local app_name=$1
  print_msg $YELLOW "Aplicando ${app_name}..."
  kubectl apply -f 6-apps/${app_name}/1-deployment.yaml
  kubectl apply -f 6-apps/${app_name}/2-svc-np.yaml
  sleep 10
  kubectl apply -f 6-apps/${app_name}/3-hpa.yaml
  print_msg $GREEN "${app_name} aplicado correctamente."
}

# Aplicar aplicaciones
apply_app "1-hello-rodov1"
apply_app "2-hello-rodov2"

print_msg $GREEN "Todas las aplicaciones han sido aplicadas correctamente."

set -e
