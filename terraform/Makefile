.PHONY: init plan apply upload-state migrate-state

ENV_FILE ?= .env.template
TF ?= terraform
OP_RUN := op run --env-file=$(ENV_FILE) --
TF_BACKEND := -input=false
STATE_FILE ?= terraform.tfstate
REMOTE_STATE_BUCKET ?= toof-infra-terraform-remote-state
REMOTE_STATE_KEY ?= terraform.tfstate
REMOTE_STATE_S3_PATH := s3://$(REMOTE_STATE_BUCKET)/$(REMOTE_STATE_KEY)
IMPORT_TARGET ?=
IMPORT_ID ?=
STATE_RM_TARGET ?=

init:
	$(OP_RUN) $(TF) init -reconfigure $(TF_BACKEND)

init-local:
	$(OP_RUN) $(TF) init

plan:
	$(OP_RUN) $(TF) plan

apply:
	$(OP_RUN) $(TF) apply

upload-state:
	AWS_REGION=ap-northeast-1 AWS_DEFAULT_REGION=ap-northeast-1 $(OP_RUN) aws s3 cp $(STATE_FILE) $(REMOTE_STATE_S3_PATH)

migrate-state:
	$(OP_RUN) $(TF) init -migrate-state -reconfigure $(TF_BACKEND)

state-list:
	$(OP_RUN) $(TF) state list

import:
	@if [ -z "$(IMPORT_TARGET)" ] || [ -z "$(IMPORT_ID)" ]; then \
		echo "Usage: make import IMPORT_TARGET=resource.name IMPORT_ID=provider-specific-id"; \
		exit 1; \
	fi
	$(OP_RUN) $(TF) import $(IMPORT_TARGET) $(IMPORT_ID)

state-rm:
	@if [ -z "$(STATE_RM_TARGET)" ]; then \
		echo "Usage: make state-rm STATE_RM_TARGET=resource.name"; \
		exit 1; \
	fi
	$(OP_RUN) $(TF) state rm $(STATE_RM_TARGET)
