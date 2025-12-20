# External Secrets Manager Bootstrap

## Google Cloud Secret Manager service account

Create the service account and IAM bindings defined in `terraform/secret_manager.tf` (managed by Terraform).

Generate a key for the service account:
```
gcloud iam service-accounts keys create key.json \
    --iam-account=external-secrets-operator@toof-infra.iam.gserviceaccount.com
```

Load the key into Kubernetes as a Secret:
```
kubectl -n external-secrets create secret generic gcp-sa-secret \
    --from-file=secret-access-credentials=./key.json
```

## 1Password service account token

During bootstrap the 1Password Service Account token is stored in Google Secret Manager and synced into Kubernetes via External Secrets Operator.
