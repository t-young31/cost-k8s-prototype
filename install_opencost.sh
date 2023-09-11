#!/bin/bash

helm repo add prometheus https://prometheus-community.github.io/helm-charts

prometheus_name="prometheus"
opencost_namespace="opencost"

helm upgrade \
    --install "$prometheus_name" prometheus/prometheus \
    --namespace prometheus \
    --create-namespace \
    --set prometheus-pushgateway.enabled=false \
    --set alertmanager.enabled=false \
    -f https://raw.githubusercontent.com/opencost/opencost/develop/kubernetes/prometheus/extraScrapeConfigs.yaml


helm repo add opencost https://opencost.github.io/opencost-helm-chart

helm upgrade \
    --install opencost opencost/opencost \
    --namespace "$opencost_namespace" \
    --create-namespace \
    --set opencost.prometheus.internal.serviceName="prometheus-server" \
    --set opencost.prometheus.internal.port="80" \
    --set opencost.prometheus.internal.namespaceName="prometheus"

echo "✅ Deployed opencost"
kubectl get pods -A

echo ""
echo "Forward the dashboard: kubectl port-forward --namespace ${opencost_namespace} service/opencost 9003 9090"
