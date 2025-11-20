data "aws_iam_policy_document" "deny_unencrypted_s3_public" {
  statement {
    sid       = "DenyS3WithoutEncryptionOrPublic"
    effect    = "Deny"
    actions   = ["s3:CreateBucket", "s3:PutBucketAcl", "s3:PutBucketPolicy"]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "s3_encryption_scp" {
  name        = "Deny-Unencrypted-Public-S3"
  description = "Ensures all S3 buckets are private and encrypted."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.deny_unencrypted_s3_public.json

  tags = var.tags
}
