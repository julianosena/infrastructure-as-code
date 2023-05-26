# Define the EBS volume
resource "aws_ebs_volume" "ebs" {
  availability_zone = "eu-west-1b"
  size              = 10
  type              = "gp2"
}