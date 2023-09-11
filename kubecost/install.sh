#!/bin/bash

namespace="kubecost"
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm upgrade \
    --install kubecost kubecost/cost-analyzer \
    --namespace "$namespace" \
    --create-namespace \
    --set kubecostToken="$KUBECOST_TOKEN"

echo "✅ Deployed kubecost"
kubectl get pods -A

echo ""
echo "Forward the dashboard: kubectl port-forward --namespace ${namespace} deployment/kubecost-cost-analyzer 9090"
