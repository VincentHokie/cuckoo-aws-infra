resource "aws_iam_instance_profile" "cuckoo_instance_profile" {
  name = "cuckoo_instance_profile"
  role = aws_iam_role.cuckoo_role.name
}

resource "aws_iam_role" "cuckoo_role" {
  name = "cuckoo_role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Principal = {
            Service = "ec2.amazonaws.com"
        },
        Effect   = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy" "cuckoo_role_policy" {
  name = "cuckoo_role_policy"
  role = aws_iam_role.cuckoo_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "s3:GetObject",
            "s3:ListBucket",
            "s3:HeadObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cuckoo_vms.bucket}/*"
        Sid = "VMDownlaodAccess"
      },{
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${aws_s3_bucket.analyses_reports.bucket}/*"
        Sid = "AnalysesUploadAccess"
      },{
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.cuckoo_key.arn
        Sid = "KMSAccess"
      }
    ]
  })
}
