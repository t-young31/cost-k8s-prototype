SHELL := /bin/bash
.PHONY: *

all: cluster open-cost

cluster:
	. init.sh && ./create_cluster.sh

open-cost:
	. init.sh && ./install_opencost.sh

destroy:
	. init.sh && \
	k3d cluster delete "$$CLUSTER_NAME"
