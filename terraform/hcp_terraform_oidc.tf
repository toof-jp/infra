locals {
  hcp_terraform_aws_sub = "organization:${tfe_organization.infra.name}:project:Default Project:workspace:${tfe_workspace.infra.name}:run_phase:*"
}

resource "google_iam_workload_identity_pool" "hcp_terraform" {
  project                   = google_project.toof_infra.project_id
  workload_identity_pool_id = "hcp-terraform"
  display_name              = "HCP Terraform"
  description               = "OIDC pool for HCP Terraform dynamic provider credentials"
  depends_on                = [google_project_service.enabled["iam.googleapis.com"]]
}

resource "google_iam_workload_identity_pool_provider" "hcp_terraform" {
  project                            = google_project.toof_infra.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.hcp_terraform.workload_identity_pool_id
  workload_identity_pool_provider_id = "hcp-terraform"
  display_name                       = "HCP Terraform"

  attribute_mapping = {
    "google.subject"                        = "assertion.sub"
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name"
    "attribute.terraform_project_name"      = "assertion.terraform_project_name"
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name"
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase"
  }

  attribute_condition = "assertion.terraform_organization_name == \"${tfe_organization.infra.name}\" && assertion.terraform_workspace_name == \"${tfe_workspace.infra.name}\""

  oidc {
    issuer_uri = "https://app.terraform.io"
  }
}

resource "google_service_account_iam_member" "terraform_sa_hcp_wiuser" {
  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.hcp_terraform.name}/attribute.terraform_workspace_name/${tfe_workspace.infra.name}"
}

data "tls_certificate" "hcp_terraform" {
  url = "https://app.terraform.io"
}

resource "aws_iam_openid_connect_provider" "hcp_terraform" {
  url             = "https://app.terraform.io"
  client_id_list  = ["aws.workload.identity"]
  thumbprint_list = [data.tls_certificate.hcp_terraform.certificates[0].sha1_fingerprint]

  tags = {
    ManagedBy = "terraform"
  }
}

data "aws_iam_policy_document" "hcp_terraform_trust" {
  statement {
    sid    = "AllowHCPTerraformAssumeRoleWithWebIdentity"
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.hcp_terraform.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "app.terraform.io:aud"
      values   = ["aws.workload.identity"]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      values   = [local.hcp_terraform_aws_sub]
    }
  }
}

resource "aws_iam_role" "hcp_terraform" {
  name               = "hcp-terraform-run"
  assume_role_policy = data.aws_iam_policy_document.hcp_terraform_trust.json

  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "hcp_terraform_assume_role" {
  role       = aws_iam_role.hcp_terraform.name
  policy_arn = aws_iam_policy.hcp_terraform_assume_role.arn
}
