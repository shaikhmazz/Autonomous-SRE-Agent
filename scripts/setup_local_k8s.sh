#!/usr/bin/env bash
# AegisMind SRE - Local Kubernetes Cluster Bootstrapper (Kind / Minikube)

set -e

CLUSTER_NAME="aegismind-local"

echo "===================================================="
echo "🛡️ Bootstrapping AegisMind SRE Local K8s Environment"
echo "===================================================="

# Check if kind is installed
if command -v kind &> /dev/null; then
    echo "Creating Kind cluster '${CLUSTER_NAME}'..."
    kind create cluster --name ${CLUSTER_NAME} || true
    kubectl cluster-info --context kind-${CLUSTER_NAME}
elif command -v minikube &> /dev/null; then
    echo "Starting Minikube..."
    minikube start --profile ${CLUSTER_NAME}
    kubectl config use-context ${CLUSTER_NAME}
else
    echo "❌ Neither 'kind' nor 'minikube' was found in PATH. Please install one of them."
    exit 1
fi

echo "Applying Kubernetes RBAC and ConfigMap..."
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/sample-app-chaos.yaml

echo "✅ Local Kubernetes Cluster initialized successfully!"
echo "Run 'python scripts/inject_incident.py --scenario OOMKilled' to trigger chaos testing."
