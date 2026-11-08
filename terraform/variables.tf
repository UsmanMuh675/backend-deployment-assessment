
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for StartupTech VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
  default     = "us-east-1b"
}

variable "public_subnet_1_cidr" {
  description = "First public subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "Second public subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "First private subnet CIDR"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_subnet_2_cidr" {
  description = "Second private subnet CIDR"
  type        = string
  default     = "10.0.12.0/24"
}

variable "my_ip" {
  description = "Your public IPv4 address with /32 for SSH access"
  type        = string
}

