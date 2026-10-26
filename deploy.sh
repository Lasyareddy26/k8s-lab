#!/bin/bash
set -e

CLUSTER=lab-cluster
IMAGE=my-app:1.0

echo ">>> Step 1: Creating kind cluster (if not already there)"
if ! kind get clusters | grep -q "^$CLUSTER$"; then
  kind create cluster --name $CLUSTER
else
  echo "Cluster $CLUSTER already exists"
fi

echo ">>> Step 2: Building Docker image"
docker build -t $IMAGE .

echo ">>> Step 3: Loading image into kind cluster"
kind load docker-image $IMAGE --name $CLUSTER

echo ">>> Step 4: Deploying to Kubernetes"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

echo ">>> Step 5: Waiting for pods to be ready"
kubectl rollout status deployment/my-app

kubectl get pods
kubectl get services

echo ">>> Done! Run this to open the app:"
echo "kubectl port-forward service/my-app-service 8081:80"
echo "Then visit http://localhost:8081"
