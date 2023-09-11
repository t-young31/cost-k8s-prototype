#!/bin/bash

function cluster_exists(){
    k3d cluster list | grep -q "$CLUSTER_NAME"
}

function create_cluster(){
  echo "Creating cluster [${CLUSTER_NAME}]"
  k3d cluster create "$CLUSTER_NAME" \
    --api-port 6550 \
    --servers 1 \
    --agents 1 \
    --port "${CLUSTER_LOAD_BALANCER_PORT}:80@loadbalancer" \
    --wait
}

function write_kube_config() {
  echo "Writing kube configuration file"
  k3d kubeconfig get "$CLUSTER_NAME" > "${CLUSTER_CONFIG_FILE}"
  chmod 600 "$CLUSTER_CONFIG_FILE"
  echo "$CLUSTER_CONFIG_FILE created. Run: export KUBECONFIG=${CLUSTER_CONFIG_FILE}"
}

if ! cluster_exists; then
  create_cluster
  write_kube_config
else
  echo "Cluster [${CLUSTER_NAME}] exists"
fi
