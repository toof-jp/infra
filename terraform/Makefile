.PHONY: init plan apply upload-state migrate-state

ENV_FILE ?= .env.template
TF ?= terraform
TF_ENV := AWS_REGION=auto AWS_DEFAULT_REGION=auto
OP_RUN := op run --env-file=$(ENV_FILE) --
# Resolve the R2 S3 endpoint from 1Password at make invocation time.
R2_ENDPOINT := $(shell op read "op://infra/terraform/remote_state_r2_s3_endpoint")
TF_BACKEND := -backend-config='endpoints={"s3"="$(R2_ENDPOINT)"}' -input=false
STATE_FILE ?= terraform.tfstate
IMPORT_TARGET ?=
IMPORT_ID ?=
STATE_RM_TARGET ?=

init:
	$(TF_ENV) $(OP_RUN) $(TF) init -reconfigure $(TF_BACKEND)

init-local:
	$(TF_ENV) $(OP_RUN) $(TF) init

plan:
	$(TF_ENV) $(OP_RUN) $(TF) plan

apply:
	$(TF_ENV) $(OP_RUN) $(TF) apply

upload-state:
	$(TF_ENV) $(OP_RUN) aws s3 cp $(STATE_FILE) s3://terraform-remote-state/terraform.tfstate --endpoint-url $(R2_ENDPOINT)

migrate-state: upload-state init

state-list:
	$(TF_ENV) $(OP_RUN) $(TF) state list

import:
	@if [ -z "$(IMPORT_TARGET)" ] || [ -z "$(IMPORT_ID)" ]; then \
		echo "Usage: make import IMPORT_TARGET=resource.name IMPORT_ID=provider-specific-id"; \
		exit 1; \
	fi
	$(TF_ENV) $(OP_RUN) $(TF) import $(IMPORT_TARGET) $(IMPORT_ID)

state-rm:
	@if [ -z "$(STATE_RM_TARGET)" ]; then \
		echo "Usage: make state-rm STATE_RM_TARGET=resource.name"; \
		exit 1; \
	fi
	$(TF_ENV) $(OP_RUN) $(TF) state rm $(STATE_RM_TARGET)
