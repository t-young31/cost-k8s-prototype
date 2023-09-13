SHELL := /bin/bash
.PHONY: *

define terraform-apply
	. init.sh $$ \
    echo "Running: terraform apply on $(1)" && \
    cd $(1) && \
	terraform init -upgrade && \
	terraform validate && \
	terraform apply --auto-approve
endef

define terraform-destroy
	. init.sh $$ \
    echo "Running: terraform destroy on $(1)" && \
    cd $(1) && \
	terraform apply -destroy --auto-approve
endef

all:
	@echo "Please select a target"; exit 1

dev:
	ENVIRONMENT=dev . init.sh && \
	./dev/create_cluster.sh && \
	$(call terraform-apply, ./deployment)

destroy:
	. init.sh && \
	k3d cluster delete "$$CLUSTER_NAME"
