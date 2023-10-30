# Define input variables
variable "region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-2"
}


variable "instance_type" {
  description = "The EC2 instance type for the web server."
  type        = string
  default     = "t2.large"
}

variable "ami_id" {
  description = "The ID of the Amazon Machine Image (AMI) for the Jenkins server."
  type        = string
  default     = "ami-02b8534ff4b424939"
}

variable "key_name" {
  description = "The name of the SSH key pair used for EC2 instances."
  type        = string
  default     = "Falcon-IB.pem"
}

variable "volume_size" {
  description = "The size of the root EC2 instances."
  type        = string
  default     = "200"
}

variable "allowed_cidr" {
  description = "The CIDR block for allowed access."
  type        = string
  default     = "50.169.74.22/32"
}

variable "vpc_id" {
  description = "The AWS VPC ID to host the Jenkins Server."
  type        = string
  default     = "vpc-0e9dc691ee99b2d99"
}

variable "public_ip" {
  description = "Configure a public ip"
  type        = bool
  default     = true
}
