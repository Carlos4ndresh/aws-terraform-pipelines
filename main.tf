provider "aws" {
    region = var.region
    version = "~>2.0"
}

module "codepipeline" {
    source = "./codepipeline"
    provisioner = var.provisioner
    repo_name = var.repo_name
    repo_branch = var.repo_branch
    owner = var.owner
    project = var.project
    env = var.env
    custodian_repo_name = var.custodian_repo_name
}