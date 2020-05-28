variable "repo_name" {
  type = string
  default = "aws-iam-infra-selfservice"
}

variable "repo_branch" {
  type = string
  default = "master"
}

variable "region" {
    type = string
    default = "us-east-1"
    description = "AWS Region"
}

variable "provisioner" {
  description = "Value to use in Provisioner tags"
  type        = string
  default     = "Terraform"
}

variable "owner" {
  type = string
  description = "resource owner"
  default = "carlos.herrera"
}

variable "project" {
  description = "Project from which is part this is resource"  
  type = string
  default = "Infrastructure Managament"
}

variable "env" {
  type = string
  description = "Environment"
  default = "Production"
}

variable "custodian_repo_name" {
  type = string
  default = "aws-custodian-rules"
}