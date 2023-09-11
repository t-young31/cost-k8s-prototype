SHELL := /bin/bash
.PHONY: *

all: cluster opencost

cluster:
	. init.sh && ./create_cluster.sh

opencost:
	. init.sh && cd opencost && ./install.sh

kubecost:
	. init.sh && cd kubecost && ./install.sh

destroy:
	. init.sh && \
	k3d cluster delete "$$CLUSTER_NAME"
