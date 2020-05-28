# aws-terraform-pipelines

Repository to create terraform CI/CD CodePipeline pipelines, and CodeBuild projects to automatically deploy resources to AWS.

## Pipelines Present

The following pipelines are created by this repo:

- _terraform_iam_codepipeline_: this pipeline controls an IAM Terraform repository for IAM resources creation.
- _terraform_custodian_codepipeline_: this pipeline controls a CloudCustodian rules repository, for automatic custodian rule creation and update.

## Repository Structure

There's a *codepipeline* folder where the codepipeline module resides. Inside this folder are the typical Terraform files (*main, outputs, variables*), where we can add new resource pipelines; or you could create additional modules for each type of pipeline you want to create.

## Heads up

- For forking this repo, take into consideration the IAM inline policies for the CodeBuild and CodePipeline resources; some resources inside those policies aren't yet taken in a variable form
- You need to take into consideration the backend configuration
- The state file is stored in S3 and there is need to have a DynamoDB table for state lock
- You'll need to know terraform to use this repo
- This repository isn't controlled by any Pipeline, to deploy this, you'll have to run the regular Terraform (validate,plan,apply) steps on your local machine.
