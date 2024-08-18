terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 2.0"
    }
  }
  backend "s3" {
    bucket = "terraform-s3-state-mark-abc123"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["C:\\Users\\Mark John\\.aws\\credentials"]

}
