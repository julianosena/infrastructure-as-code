data "aws_region" "current" {}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "access" {
  key_name  = "access"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw2EVwipyzrziEOnyzke0N+DilUnSVEE7c7H7I5IbqZ1dhuKb8OlFw4zbbO7EtNyk8IySlSdacJucmxAooNmDikCUPmXHjbmAwZBUoHkjsewmKn6hhA5vD9rUJZvSyZP2PFUXVFQNCqg8RsEAsU06hfdVAdDbYttZ1VwNnMIRWM4iICcLmFhAApumAI8p2wUa57McJJxX//rQA2bqEvyVkJ+WjvJ+MirIWElKevWTGV1vateBar5sBhO7JEO7wHVWXTu0t+hmLRWLPuZw0IPUHaNQr3Ku/sonfU/KAsA12UZrGnGubeMNFnDQXYI+ktYZxVcOcBppUAT4R+t6k9pOx"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "${var.project}-Network"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-IGW"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.11.0/24"
  map_public_ip_on_launch = true

  availability_zone = "eu-west-1a"

  tags = {
    Name = "${var.project}-PublicSubnet-A"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"

  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"

  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.21.0/24"
  map_public_ip_on_launch = true

  availability_zone = "eu-west-1b"

  tags = {
    Name = "${var.project}-PublicSubnet-B"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-PublicRouteTable"
  }
}

resource "aws_route" "local_route" {
  route_table_id          = aws_route_table.public_route_table.id
  destination_cidr_block  = aws_vpc.main.cidr_block
  local_gateway_id        = "local"
}

resource "aws_route" "igw_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.access.key_name

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/aws/access.pem")
      host        = self.public_ip
    }
  }
}