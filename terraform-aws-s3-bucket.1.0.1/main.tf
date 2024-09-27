
resource "aws_s3_bucket" "default" {
  #checkov:skip=CKV_AWS_145:Ensure that S3 buckets are encrypted with KMS by default
  bucket              = var.bucket_name
  force_destroy       = var.delete_bucket
  object_lock_enabled = var.enable_object_locking


  tags = merge({
    Name              = var.bucket_name
    project           = var.project
    ManagedBy         = "Terraform"
    security_hardened = true
    # Does this bucket contains secrets?
    security_classification = false
    # What privacy classification of data stored(EXPOSED_PERSONAL_DATA,
    # PRIVATE_PERSONAL_DATA, CRITICAL_DATA or OTHER_DATA for non-classified)
    privacy_classification = "OTHER_DATA"
  }, var.tags)
}

moved {
  from = aws_s3_bucket_acl.default
  to   = aws_s3_bucket_acl.default[0]
}


resource "aws_s3_bucket_versioning" "default" {
  bucket = aws_s3_bucket.default.id
  versioning_configuration {
    status = var.versioning_status
  }
}

