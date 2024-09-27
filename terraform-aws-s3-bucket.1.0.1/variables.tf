variable "bucket_name" {
  type        = string
  description = "S3 bucket name."
  validation {
    condition     = can(regex("(^(([a-z0-9]|[a-z0-9][a-z0-9\\-]*[a-z0-9])\\.)*([a-z0-9]|[a-z0-9][a-z0-9\\-]*[a-z0-9])$)", var.bucket_name))
    error_message = "ERROR: S3 bucket name must conform to the bucket naming conventions. Please checkout the naming convention here, https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html."
  }
}

variable "project" {
  type        = string
  description = "Valid scry project to track ownership."
}

variable "environment" {
  type    = string
  default = null
}

variable "acl" {
  type        = string
  description = "S3 bucket ACL"
  default     = "private"
}

variable "object_ownership" {
  type        = string
  description = "Object ownership. Valid values: BucketOwnerPreferred, ObjectWriter or BucketOwnerEnforced."
  default     = "ObjectWriter"
}

variable "grant" {
  type        = any # TODO: use optional object fields once it's officially supported by Terraform
  description = "ACL policy grants"
  default     = []
}

variable "versioning_status" {
  type    = string
  default = "Enabled"
  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.versioning_status)
    error_message = "Valid values are Enabled, Suspended, Disabled."
  }
  description = "Versioning state of the bucket."
}

variable "sse_algorithm" {
  type    = string
  default = "AES256"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "Valid values are AES256, aws:kms."
  }
  description = "Server-side encryption algorithm to use. Valid values are AES256, aws:kms."
}

variable "kms_master_key_id" {
  type        = string
  default     = null
  description = "AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms"
}

variable "s3_replica_enabled" {
  type        = bool
  default     = false
  description = "Set this value to true to enable replication."
}

variable "s3_replica_bucket_arn" {
  type        = string
  description = "Replica bucket arn"
  default     = ""
}

variable "s3_replica_role" {
  type        = string
  description = "IAM role for Amazon S3 to assume when replicating the objects."
  default     = "ReplicateS3AbbBackups"
}

variable "override_replica_ownership" {
  type        = bool
  description = "Set this to tre to change replica ownership to the AWS account that owns the destination buckets."
  default     = true
}

variable "bucket_policy" {
  type        = string
  default     = "s3_default_policy"
  description = "By default this module uses airbnb specific secure bucket policy."
  validation {
    condition     = contains(["s3_default_policy", "public_read_object", "allow_put_object_acl_policy", "inventory_bucket_default_policy", "logging_bucket_default_policy"], var.bucket_policy)
    error_message = "The bucket policy must be one of the following values s3_default_policy, public_read_object, allow_put_object_acl_policy. If you wish to add new policies, please contact the Security team."
  }
}

variable "custom_bucket_policies" {
  type        = list(string)
  default     = []
  description = "A list of custom policies that are merged with the default bucket policy."
}

variable "cors_rules" {
  description = "Rules for Cross-Origin Resource Sharing"
  type        = any # TODO: use optional object fields once it's officially supported by Terraform
  default     = null
}

variable "website" {
  description = "Static website hosting configuration."
  type        = map(string)
  default     = null
}

variable "delete_bucket" {
  type        = bool
  default     = false
  description = "Set it to true, to delete the objects in the bucket."
}

variable "expiration_days" {
  type        = number
  default     = 0
  description = "Days after object creation to expire."
}

variable "noncurrent_expiration_days" {
  type        = number
  default     = 14
  description = "Days after noncurrent object versions to expire."
}

variable "abort_incomplete_multipart_upload_days" {
  type        = number
  default     = 2
  description = "Days after initiating a multipart upload when the multipart upload must be completed."
}

variable "transition_storage_class" {
  description = "Storage class to transition to."
  type        = string
  default     = null
}

variable "transition_days" {
  description = "Number of days before transitioning objects"
  type        = number
  default     = null
}

variable "noncurrent_transition_days" {
  description = "Number of days before transitioning noncurrent object versions"
  type        = number
  default     = null
}

variable "lifecycle_rules" {
  description = "Per prefix expiration rules."
  type        = list(any)
  default     = []
}

variable "disaster_recovery_account_id" {
  type        = string
  description = "Disaster recovery account id."
}

variable "s3_logging_bucket" {
  type        = string
  description = "Logging bucket to log S3 API actions."
}

variable "s3_logging_prefix" {
  type        = string
  description = "A prefix for all log object keys."
}

variable "dr_storage_class" {
  type        = string
  default     = "GLACIER"
  description = "Disaster recovery storage class."
  validation {
    condition     = contains(["GLACIER", "STANDARD", "DEEP_ARCHIVE"], var.dr_storage_class)
    error_message = "Invalid disaster recovery storage class. Must be one of $${data.s3_disaster_recovery_storage_class.dr_classes.value}."
  }
}

variable "s3_inventory_bucket" {
  type        = string
  description = "Destination bucket to publish the inventory results."
}

variable "inventory_frequency" {
  type        = string
  description = "Specifies how frequently inventory results are produced."
  default     = "Weekly"
  validation {
    condition     = contains(["Daily", "Weekly"], var.inventory_frequency)
    error_message = "Invalid bucket inventory frequency. Valid values: Daily, Weekly."
  }
}

variable "inventory_optional_fields" {
  type        = list(string)
  description = "List of optional fields that are included in the inventory results."
  default     = ["Size", "LastModifiedDate", "StorageClass", "ETag", "IsMultipartUploaded", "ReplicationStatus", "EncryptionStatus"]
}

variable "public_access_block" {
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = false
    restrict_public_buckets = false
  }
  description = "Public Access Block configuration."
}

/*data "http" "scry_all_projects" {
  url = "https://scry.d.musta.ch/v1/projects"
  request_headers = {
    "Accept" = "application/json"
  }
}
# This is a terraform.io public registry verified module.
module "verify_scry_projects" {
  source  = "gordonbondon/verify/common"
  version = "1.0.0"
  match = contains(distinct([for project in jsondecode(data.http.scry_all_projects.body).projects : project.project_name
  ]), var.project)
  error = "Project name must be a valid scry project. Please verify your project name here, https://scry.d.musta.ch/v1/projects."
}*/

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to assign to the bucket."

  validation {
    condition     = !contains(keys(var.tags), "Name") && !contains(keys(var.tags), "environment") && !contains(keys(var.tags), "ManagedBy")
    error_message = "The following tags cannot be overridden: Name, environment, ManagedBy."
  }
}

variable "enable_object_locking" {
  type        = bool
  default     = false
  description = "Set it to true, to enable object locking on the bucket, must be done at creation time"
}

variable "enable_object_locking_token" {
  type        = string
  default     = null
  description = "Please provide a token to enable bucket replication when using object locking. This token is an opaque field given by AWS support"
}


data "aws_caller_identity" "current" {}
