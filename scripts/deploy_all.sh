#!/usr/bin/env bash
# AegisMind SRE Master Deployment Automation Script

set -e

ENV=${1:-dev}

echo "=================================================="
echo "🛡️ Deploying AegisMind SRE Platform [Env: ${ENV}]"
echo "=================================================="

# 1. Provision Infrastructure via Terraform
echo "Step 1: Applying Terraform Infrastructure..."
cd terraform
terraform init
terraform plan -var-file="environments/${ENV}/terraform.tfvars"
terraform apply -auto-approve -var-file="environments/${ENV}/terraform.tfvars"
cd ..

# 2. Build & Push Docker Container
echo "Step 2: Building AegisMind Engine Docker Image..."
docker build -t aegismind-sre-engine:latest app/

# 3. Deploy Kubernetes Manifests
echo "Step 3: Applying Kubernetes Control Plane Manifests..."
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml

echo "✅ Master Deployment Complete! Control plane is live."
