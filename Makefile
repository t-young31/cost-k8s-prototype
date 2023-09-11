SHELL := /bin/bash
.PHONY: *

all:
	. init.sh && \
	./create_cluster.sh

destroy:
	. init.sh && \
	k3d cluster delete "$$CLUSTER_NAME"
