#!/bin/bash
set -e

echo "🚀 Deploying RxPulse to PROD environment..."

echo "1/3 Applying Namespace and Secrets (Wave -1)..."
kubectl apply -f environments/prod/namespace.yaml
kubectl apply -f environments/prod/sealed-secret.yaml

echo "2/3 Deploying Infrastructure (Waves 0 & 1)..."
helm upgrade --install rxpulse-base ./infra/base -n rxpulse-prod -f environments/prod/values.yaml
helm upgrade --install rxpulse-mongodb ./infra/mongodb -n rxpulse-prod -f environments/prod/values.yaml
helm upgrade --install rxpulse-gateway ./infra/gateway -n rxpulse-prod -f environments/prod/values.yaml

echo "3/3 Deploying Microservices (Wave 2)..."
helm upgrade --install rxpulse-user ./charts/user -n rxpulse-prod -f environments/prod/values.yaml
helm upgrade --install rxpulse-catalog ./charts/catalog -n rxpulse-prod -f environments/prod/values.yaml
helm upgrade --install rxpulse-inventory ./charts/inventory -n rxpulse-prod -f environments/prod/values.yaml
helm upgrade --install rxpulse-frontend ./charts/frontend -n rxpulse-prod -f environments/prod/values.yaml

echo "✅ Deployment commands issued. Checking status..."
kubectl get pods -n rxpulse-prod
