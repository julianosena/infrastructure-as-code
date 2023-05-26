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

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.instance_security_group.id]
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

resource "aws_instance" "processor" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.instance_security_group.id]
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

# Attach the EBS volume to the EC2 instance
resource "aws_volume_attachment" "ec2_attachment_ebs_volume" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.web.id
}

# Attach the EBS volume to the EC2 instance
resource "aws_volume_attachment" "ec2_attachment_ebs_volume_process" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.processor.id
}