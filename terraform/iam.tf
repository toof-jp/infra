data "aws_caller_identity" "current" {}

locals {
  terraform_user_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
  terraform_role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/terraform-management"
  hcp_terraform_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/hcp-terraform-run"
  terraform_policy_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/TerraformManagementPolicy",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/TerraformUserAssumeRole",
  ]
}

data "aws_iam_policy_document" "terraform_management" {
  statement {
    sid = "ManageTerraformUser"
    actions = [
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:GetUser",
      "iam:ListAttachedUserPolicies",
      "iam:ListGroupsForUser",
      "iam:ListUserPolicies",
      "iam:ListUserTags",
      "iam:TagUser",
      "iam:UntagUser",
    ]
    resources = [local.terraform_user_arn]
  }

  statement {
    sid = "ManageTerraformRole"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]
    resources = [
      local.terraform_role_arn,
      local.hcp_terraform_role_arn,
    ]
  }

  statement {
    sid = "ManageTerraformPolicies"
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyTags",
      "iam:ListPolicyVersions",
      "iam:SetDefaultPolicyVersion",
      "iam:TagPolicy",
      "iam:UntagPolicy",
    ]
    resources = local.terraform_policy_arns
  }

  statement {
    sid = "AttachManagedTerraformPolicies"
    actions = [
      "iam:AttachRolePolicy",
      "iam:AttachUserPolicy",
      "iam:DetachRolePolicy",
      "iam:DetachUserPolicy",
    ]
    resources = [
      local.terraform_user_arn,
      local.terraform_role_arn,
      local.hcp_terraform_role_arn,
    ]
    condition {
      test     = "ArnEquals"
      variable = "iam:PolicyARN"
      values   = local.terraform_policy_arns
    }
  }

  statement {
    sid = "ManageS3AccountLevel"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListAccessPoints",
      "s3:ListAccessPointsForObjectLambda",
      "s3:GetAccountPublicAccessBlock",
      "s3:PutAccountPublicAccessBlock",
      "s3:GetStorageLensConfiguration",
      "s3:ListJobs",
      "s3:CreateJob",
      "s3:DescribeJob",
      "s3:UpdateJobPriority",
      "s3:UpdateJobStatus"
    ]
    resources = ["*"]
  }

  statement {
    sid = "ManageS3BucketsAndObjects"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::*",
      "arn:aws:s3:::*/*"
    ]
  }
}

resource "aws_iam_policy" "terraform_management" {
  name        = "TerraformManagementPolicy"
  description = "Allows Terraform to manage IAM and S3 resources."
  policy      = data.aws_iam_policy_document.terraform_management.json
}

data "aws_iam_policy_document" "terraform_role_trust" {
  statement {
    sid    = "AllowHCPTerraformRunRoleAssumeRole"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.hcp_terraform.arn]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "terraform" {
  name               = "terraform-management"
  assume_role_policy = data.aws_iam_policy_document.terraform_role_trust.json

  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "terraform_management" {
  role       = aws_iam_role.terraform.name
  policy_arn = aws_iam_policy.terraform_management.arn
}

data "aws_iam_policy_document" "hcp_terraform_assume_role" {
  statement {
    sid     = "AllowAssumeTerraformManagementRole"
    actions = ["sts:AssumeRole"]
    resources = [
      aws_iam_role.terraform.arn
    ]
  }
}

resource "aws_iam_policy" "hcp_terraform_assume_role" {
  name        = "TerraformUserAssumeRole"
  description = "Allows the HCP Terraform run role to assume the terraform-management role."
  policy      = data.aws_iam_policy_document.hcp_terraform_assume_role.json
}

moved {
  from = aws_iam_policy.terraform_user_assume_role
  to   = aws_iam_policy.hcp_terraform_assume_role
}
