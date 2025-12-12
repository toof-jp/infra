.PHONY: init plan apply upload-state migrate-state

ENV_FILE ?= .env.template
TF ?= terraform
TF_ENV := AWS_REGION=auto AWS_DEFAULT_REGION=auto
OP_RUN := op run --env-file=$(ENV_FILE) --
# Resolve the R2 S3 endpoint from 1Password at make invocation time.
R2_ENDPOINT := $(shell op read "op://infra/terraform/remote_state_r2_s3_endpoint")
TF_BACKEND := -backend-config='endpoints={"s3"="$(R2_ENDPOINT)"}' -input=false

init:
	$(TF_ENV) $(OP_RUN) $(TF) init -reconfigure $(TF_BACKEND)

plan:
	$(TF_ENV) $(OP_RUN) $(TF) plan

apply:
	$(TF_ENV) $(OP_RUN) $(TF) apply

upload-state:
	$(TF_ENV) $(OP_RUN) aws s3 cp terraform.tfstate s3://terraform-remote-state/terraform.tfstate --endpoint-url $(R2_ENDPOINT)

migrate-state: upload-state init
