
resource "aws_instance" "cuckoo_server" {
  ami           = "ami-03e848ff8424083f8"
  instance_type = "c5.metal"

  key_name = "project-c"

  associate_public_ip_address = true
  availability_zone = "us-east-1a"
  ebs_optimized = true
  # iam_instance_profile =
  subnet_id = aws_subnet.cuckoo_us_east_1a_subnet.id
  security_groups = [aws_security_group.allow_tls.id]
  monitoring = true

  root_block_device {
    volume_size = 80
  }

}
