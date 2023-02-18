resource "aws_kms_key" "cuckoo_key" {
  description             = "Cuckoo key for encryption at rest and in transit"
  deletion_window_in_days = 10
}