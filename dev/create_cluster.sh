#!/bin/bash

function cluster_exists(){
    k3d cluster list | grep -q "$DEV_CLUSTER_NAME"
}

function create_cluster(){
  echo "Creating cluster [${DEV_CLUSTER_NAME}]"
  k3d cluster create "$DEV_CLUSTER_NAME" \
    --api-port 6550 \
    --servers 1 \
    --agents 1 \
    --port "${DEV_CLUSTER_LOAD_BALANCER_PORT}:443@loadbalancer" \
    --wait
}

function write_kube_config() {
  echo "Writing kube configuration file"
  k3d kubeconfig get "$DEV_CLUSTER_NAME" > "${DEV_CLUSTER_CONFIG_FILE}"
  chmod 600 "$DEV_CLUSTER_CONFIG_FILE"
  echo "$DEV_CLUSTER_CONFIG_FILE created. Run: export KUBECONFIG=${DEV_CLUSTER_CONFIG_FILE}"
}

if ! cluster_exists; then
  create_cluster
  write_kube_config
else
  echo "Cluster [${DEV_CLUSTER_NAME}] exists"
fi
