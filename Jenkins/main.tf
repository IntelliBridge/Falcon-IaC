terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

# AWS EC2 Instance for Jenkins
resource "aws_instance" "Jenkins" {
  
  ami           = var.ami_id
  instance_type = var.instance_type

  # Associate a public IP with the instance
  associate_public_ip_address = var.public_ip

  key_name      = var.key_name

  root_block_device {
    volume_type           = "gp2"   # General Purpose SSD (gp2)
    volume_size           = var.volume_size     # Size of the root volume in GB
    delete_on_termination = true
  }

  user_data = file("user_data.sh")

  tags = {
    Name = "Jenkins"
  }
}


# Wait until EC2 is created, then login and fetch the Jenkins Password
resource "null_resource" "jenkins_password" {

  connection {
      type        = "ssh"
      host        = aws_instance.Jenkins.public_ip
      private_key = file("${path.cwd}/../ssh-keys/${var.key_name}.pem")
      user        = "ec2-user"
  }

 ## 1. Connect to the host
 ## 2. Check to see if the Jenkins Admin Password is ready, once it's ready fetch the Jenkins URL & Password 
 ## 3. Fetch the Sonarqube URL & Admin Password

  provisioner "remote-exec" {

  inline = [
    "sleep 420",
    "echo -e \"Jenkins URL: ${aws_instance.Jenkins.public_ip}:8080\"",
    "echo -e \"Jenkins Admin Password: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)\"",
    "echo -e \"Sonarqube URL: ${aws_instance.Jenkins.public_ip}:9000\"",
    "echo -e \"Sonarqube Admin Password: MySonarAdminPassword\"",
    ]
  }
}

# Security Group for Jenkins Instance
resource "aws_security_group" "Jenkins" {
  name        = "Jenkins"
  description = "Allow Jenkins inbound traffic"
  vpc_id      = var.vpc_id

  # Ingress rules
  ingress = [{
    description      = "Jenkins Port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = [var.allowed_cidr]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  },
    {
    description      = "SSH into server"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.allowed_cidr]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  },
  {
    description      = "Owasp Zap scans "
    from_port        = 8090
    to_port          = 8090
    protocol         = "tcp"
    cidr_blocks      = [var.allowed_cidr]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  },
  {
    description      = "Sonarqube"
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    cidr_blocks      = [var.allowed_cidr]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }
  ]

  # Egress rules
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Jenkins"
  }
}

# Attach Security Group to the Jenkins Network Interface
resource "aws_network_interface_sg_attachment" "Jenkins_sg_attachment" {
  security_group_id    = aws_security_group.Jenkins.id
  network_interface_id = aws_instance.Jenkins.primary_network_interface_id
}
