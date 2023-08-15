terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.1.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  shared_config_files      = ["./.aws_credentials/config"]
  shared_credentials_files = ["./.aws_credentials/credentials"]
  profile                  = var.aws_user_profile
}

provider "ansible" {
  # Configuration options
}
