terraform { 
  cloud { 
    organization = "tafe" 

    workspaces { 
      name = "wiz-iac-testing-711" 
    } 
  } 
}

provider "aws" {
  region = "us-east-1"
}

module "s3_bucket" {
  source          = "./terraform-aws-s3-bucket.1.0.1"
  bucket_name     = "my-unique-bucket-name-baoxu-20240927-test" 
  versioning_status = "Enabled"
  project = "test"
  s3_inventory_bucket = "test"
  disaster_recovery_account_id = "1223"
  s3_logging_bucket = "test"
  s3_logging_prefix = "test"
}