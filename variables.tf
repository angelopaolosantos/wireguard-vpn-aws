variable "aws_user_profile" {
  default = "angelo" # Update to aws user profile name in credentials
}

variable "instance_type" {
  # default = "t3.micro"
  default = "t3.micro"
}

variable "instance_ami" {
  default = "ami-08766f81ab52792ce" # Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
}

variable "instance_user" {
  default = "ubuntu"
}
