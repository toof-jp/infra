# Google Cloud Secret Manager
## service account
service accountの作成

`terraform/google/secret_manager.tf`にSecret Manger用のservice accountとIAMロールの定義がある

service account keyの作成
```
gcloud iam service-accounts keys create key.json \
    --iam-account=external-secrets-operator@toof-infra.iam.gserviceaccount.com
```

service account keyをKubernetesのSecretに登録
```
kubectl -n external-secrets create secret generic gcp-sa-secret \
    --from-file=secret-access-credentials=./key.json
```
