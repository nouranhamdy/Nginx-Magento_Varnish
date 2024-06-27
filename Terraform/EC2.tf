resource "aws_instance" "magento-server" {
  ami                    = "ami-026c3177c9bd54288"
  instance_type          = "t2.medium"
  subnet_id              = "subnet-0bfc43ea90f2e89b4"
  key_name               = aws_key_pair.magento_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  root_block_device {
    volume_size= 12
  }

  tags = {
    Name = "magento-server"
  }
}

# resource "aws_ebs_volume" "magento-ebs" {
#   availability_zone = "eu-central-1a"
#   size              = 12
#   tags = {
#     Name = "magento-ebs"
#   }
# }

# resource "aws_volume_attachment" "ebs_attachement" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.magento-ebs.id
#   instance_id = aws_instance.magento-server.id
# }

resource "aws_eip" "magento-eip" {
  instance = aws_instance.magento-server.id
  domain   = "vpc"
  provisioner "local-exec" {      
    command = "echo '[magento-servers]\n${aws_eip.magento-eip.public_ip}' > ../Ansible/inventory" 
    }
}

resource "tls_private_key" "magento_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "magento_key" {
  key_name   = "magento_key"
  public_key = tls_private_key.magento_key.public_key_openssh
}

resource "local_file" "magento_key" {
  content  = tls_private_key.magento_key.private_key_pem
  filename = "${path.module}/magento_key.pem"
  provisioner "local-exec" {      
    command = "chmod 400 ${path.module}/magento_key.pem" 
    }
}


resource "aws_security_group" "ec2_security_group" {
  name        = "magento-SG"
  description = "Allow SSH inbound traffic"

  # Allow SSH inbound for allowed IP addressess
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TCP port 80 for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TCP port 443 for HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound HTTP to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound HTTPS to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}