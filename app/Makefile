SHELL := /bin/bash
.PHONY: *

build:
	docker build --tag ocost .

build-x86:
	. ../init.sh && \
	docker buildx build \
		--label org.opencontainers.image.source="https://github.com/$$GITHUB_REPO" \
		--platform linux/amd64 \
		--tag ocost \
		.

push: build-x86
	. ../init.sh && \
	docker tag ocost "$$ocost_IMAGE" && \
	docker push "$$ocost_IMAGE"
