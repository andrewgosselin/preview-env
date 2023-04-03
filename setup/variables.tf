variable "aws_role" {
}

variable "domain_name" {
}

variable "manager_repository" {
}

terraform {
  required_providers {
    spacelift = {
      source = "spacelift.io/spacelift-io/spacelift"
    }
  }
}

provider "spacelift" {}
