#!/bin/bash

k3d image import -c "$DEV_CLUSTER_NAME" -m direct "$APP_IMAGE"
