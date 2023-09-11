#!/bin/bash


prometheus_name="prometheus"
opencost_namespace="opencost"

helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm upgrade \
    --install "$prometheus_name" prometheus/prometheus \
    --namespace prometheus \
    --create-namespace \
    --set prometheus-pushgateway.enabled=false \
    --set alertmanager.enabled=false \
    -f https://raw.githubusercontent.com/opencost/opencost/develop/kubernetes/prometheus/extraScrapeConfigs.yaml


kubectl apply -f configmap.yaml -n "$opencost_namespace"

helm repo add opencost https://opencost.github.io/opencost-helm-chart
helm upgrade \
    --install opencost opencost/opencost \
    --namespace "$opencost_namespace" \
    --create-namespace \
    --set opencost.prometheus.internal.serviceName="prometheus-server" \
    --set opencost.prometheus.internal.port="80" \
    --set opencost.prometheus.internal.namespaceName="prometheus" \
    --set opencost.exporter.extraEnv.CONFIG_PATH="/tmp/custom-config" \
    --set extraVolumes[0].name="custom-configs" \
    --set extraVolumes[0].configMap.name="opencost-conf"


echo "✅ Deployed opencost"
kubectl get pods -A

echo ""
echo "Forward the dashboard: kubectl port-forward --namespace ${opencost_namespace} service/opencost 9003 9090"
