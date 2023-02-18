
resource "aws_s3_bucket" "analyses_reports" {
  bucket = "final-project-cuckoo-analyses"
}

resource "aws_s3_bucket" "cuckoo_vms" {
  bucket = "final-project-cuckoo-vms"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "analyses_reports_encryption_config" {
  bucket = aws_s3_bucket.analyses_reports.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cuckoo_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cuckoo_vms_encryption_config" {
  bucket = aws_s3_bucket.cuckoo_vms.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cuckoo_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "block_public_analyses_reports" {
  bucket = aws_s3_bucket.analyses_reports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_public_access_block" "block_public_cuckoo_vms" {
  bucket = aws_s3_bucket.cuckoo_vms.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}