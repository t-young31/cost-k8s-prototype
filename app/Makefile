SHELL := /bin/bash
.PHONY: *

build:
	. ../init.sh && \
	cd ocost && \
	docker build --tag "$$APP_IMAGE" .

test-and-exit:
	cd tests && \
	docker compose up --exit-code-from curl --build
