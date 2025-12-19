data "aws_iam_policy_document" "terraform_management" {
  statement {
    sid     = "ManageIAM"
    actions = ["iam:*"]
    resources = [
      "*"
    ]
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

resource "aws_iam_user" "terraform" {
  name = "terraform"

  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_iam_policy" "terraform_management" {
  name        = "TerraformManagementPolicy"
  description = "Allows Terraform to manage IAM and S3 resources."
  policy      = data.aws_iam_policy_document.terraform_management.json
}

data "aws_iam_policy_document" "terraform_role_trust" {
  statement {
    sid    = "AllowTerraformUserAssumeRole"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.terraform.arn]
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

data "aws_iam_policy_document" "terraform_user_assume_role" {
  statement {
    sid     = "AllowAssumeTerraformManagementRole"
    actions = ["sts:AssumeRole"]
    resources = [
      aws_iam_role.terraform.arn
    ]
  }
}

resource "aws_iam_policy" "terraform_user_assume_role" {
  name        = "TerraformUserAssumeRole"
  description = "Allows the terraform IAM user to assume the terraform-management role."
  policy      = data.aws_iam_policy_document.terraform_user_assume_role.json
}

resource "aws_iam_user_policy_attachment" "terraform_assume_role" {
  user       = aws_iam_user.terraform.name
  policy_arn = aws_iam_policy.terraform_user_assume_role.arn
}
