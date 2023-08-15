resource "aws_vpc" "alpha_vpc" {
  cidr_block           = "10.10.10.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name"            = "alpha_vpc"
    "terraform_group" = "wireguard_vpn_aws"
  }
}

resource "aws_vpc" "beta_vpc" {
  cidr_block           = "10.10.11.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name"            = "beta_vpc"
    "terraform_group" = "wireguard_vpn_aws"
  }
}

resource "aws_subnet" "alpha_subnet" {
  vpc_id     = aws_vpc.alpha_vpc.id
  cidr_block = "10.10.10.0/24"
  tags = {
    "Name"            = "alpha_subnet"
    "terraform_group" = "wireguard_vpn_aws"
  }
}

resource "aws_subnet" "beta_subnet" {
  vpc_id     = aws_vpc.beta_vpc.id
  cidr_block = "10.10.11.0/24"
  tags = {
    "Name"            = "beta_subnet"
    "terraform_group" = "wireguard_vpn_aws"
  }
}

resource "aws_security_group" "alpha_sg" {
  vpc_id = aws_vpc.alpha_vpc.id
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "Allow ping request"
      from_port        = -1
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "icmp"
      security_groups  = []
      self             = false
      to_port          = -1
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "Allow SSH connection"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "Wireguard port requirement"
      from_port        = 51000
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "udp"
      security_groups  = []
      self             = false
      to_port          = 51000
    },
  ]
  name = "alpha_sg"
  tags = {
    "Name" = "alpha_security_group"
    "terraform_group" = "wireguard_vpn_aws"
  }
}

resource "aws_security_group" "beta_sg" {
  vpc_id = aws_vpc.beta_vpc.id
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "Allow ping request"
      from_port        = -1
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "icmp"
      security_groups  = []
      self             = false
      to_port          = -1
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "Allow SSH connection"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "Wireguard port requirement"
      from_port        = 51000
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "udp"
      security_groups  = []
      self             = false
      to_port          = 51000
    },
  ]
  name = "beta_sg"
  tags = {
    "Name" = "beta_security_group"
    "terraform_group" = "wireguard_vpn_aws"
  }
}

resource "aws_internet_gateway" "alpha_igw" {
  vpc_id = aws_vpc.alpha_vpc.id
  tags = {
    "Name"            = "alpha_igw"
    "terraform_group" = "wireguard_vpn_aws"
  }
}

resource "aws_internet_gateway" "beta_igw" {
  vpc_id = aws_vpc.beta_vpc.id
  tags = {
    "Name"            = "beta_igw"
    "terraform_group" = "wireguard_vpn_aws"
  }
}

resource "aws_route" "alpha_route_1" {
  route_table_id         = aws_vpc.alpha_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.alpha_igw.id
}

resource "aws_route" "alpha_route_2" {
  route_table_id         = aws_vpc.alpha_vpc.default_route_table_id
  destination_cidr_block = "10.10.11.0/24"
  network_interface_id   = aws_instance.alpha_wireguard.primary_network_interface_id
  depends_on             = [aws_instance.alpha_wireguard]
}

resource "aws_route" "beta_route_1" {
  route_table_id         = aws_vpc.beta_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.beta_igw.id
}

resource "aws_route" "beta_route_2" {
  route_table_id         = aws_vpc.beta_vpc.default_route_table_id
  destination_cidr_block = "10.10.10.0/24"
  network_interface_id   = aws_instance.beta_wireguard.primary_network_interface_id
  depends_on             = [aws_instance.beta_wireguard]
}

resource "aws_route_table_association" "alpha_rt_association" {
  subnet_id      = aws_subnet.alpha_subnet.id
  route_table_id = aws_vpc.alpha_vpc.default_route_table_id
}

resource "aws_route_table_association" "beta_rt_association" {
  subnet_id      = aws_subnet.beta_subnet.id
  route_table_id = aws_vpc.beta_vpc.default_route_table_id
}

resource "aws_instance" "alpha_wireguard" {
  ami                         = var.instance_ami
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.wireguard_kp.key_name
  subnet_id                   = aws_subnet.alpha_subnet.id
  tags = {
    "Name" = "alpha_wireguard"
    "terraform_group" = "wireguard_vpn_aws"
  }
  security_groups = [aws_security_group.alpha_sg.id]
}

resource "aws_instance" "beta_wireguard" {
  ami                         = var.instance_ami
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.wireguard_kp.key_name
  subnet_id                   = aws_subnet.beta_subnet.id
  tags = {
    "Name" = "beta_wireguard"
    "terraform_group" = "wireguard_vpn_aws"
  }
  security_groups = [aws_security_group.beta_sg.id]
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "wireguard_kp" {
  key_name   = "wireguard_key" # Create a "myKey" on AWS.
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Copy a "myKey.pem" to local computer.
    command = "echo '${tls_private_key.pk.private_key_pem}' > ${path.cwd}/wireguard_key.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 ${path.cwd}/wireguard_key.pem"
  }

  tags = {
    terraform_group = "wireguard_vpn_aws"
  }
}

# Ansible Section 

resource "ansible_host" "alpha_host" {
  name   = aws_instance.alpha_wireguard.public_dns
  groups = ["alpha"]
  variables = {
    ansible_user                 = var.instance_user
    ansible_ssh_private_key_file = "./wireguard_key.pem"
    ansible_python_interpreter   = "/usr/bin/python3"
    host_name                    = aws_instance.alpha_wireguard.tags["Name"]
    greetings                    = "from host!"
    some                         = "variable"
    private_ip                   = aws_instance.alpha_wireguard.private_ip
  }
}

resource "ansible_host" "beta_host" {
  name   = aws_instance.beta_wireguard.public_dns
  groups = ["beta"]
  variables = {
    ansible_user                 = var.instance_user
    ansible_ssh_private_key_file = "./wireguard_key.pem"
    ansible_python_interpreter   = "/usr/bin/python3"
    host_name                    = aws_instance.beta_wireguard.tags["Name"]
    greetings                    = "from host!"
    some                         = "variable"
    private_ip                   = aws_instance.beta_wireguard.private_ip
  }
}