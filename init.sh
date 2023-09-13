#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
env_filepath="$SCRIPT_DIR/.env"

if [ ! -f "$env_filepath" ]; then
    echo "$env_filepath not found. Please create it from .env.sample"
    exit 1
fi

opencost_json_filepath="$SCRIPT_DIR/opencost.json"

if [ ! -f "$opencost_json_filepath" ]; then
    echo "$opencost_json_filepath not found. Please create it from opencost.sample.json"
    exit 1
fi

echo "Exporting variables in ${env_filepath} file into the environment"
read -ra args < <(grep -v '^#' "$env_filepath" | xargs)
export "${args[@]}"

if [ "${ENVIRONMENT:-}" = "dev" ]; then
    export KUBE_CONFIG_PATH="${SCRIPT_DIR}/${DEV_CLUSTER_CONFIG_FILE}"
    export TF_VAR_https_port="$DEV_CLUSTER_LOAD_BALANCER_PORT"
else
    export TF_VAR_https_port="443"
fi
