resource "aws_iam_role" "terraform_iam_codebuild_role" {
  name = "terraform_iam_codebuild_role"
  
  tags = {
      env = var.env,
      Provisioner = var.provisioner,
      owner = var.owner,
      project = var.project
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "terraform_iam_codebuild_role_policy" {
  name = "terraform-iam-codebuild-role-policy"
  role = aws_iam_role.terraform_iam_codebuild_role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "FullIAMAccess",
      "Action": "iam:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "FullLambdaAccess",
      "Action": "lambda:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "S3CodePipelineAccess",
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "kmsCodePipelineFullAccess",
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "CodeBuildFullAccessOnSelf",
      "Action": "codebuild:*",
      "Effect": "Allow",
      "Resource": "${aws_codebuild_project.terraform_iam_codebuild_project.id}"
    },
    {
      "Sid": "CodePipelineAccesss",
      "Action": [
        "codepipeline:GetPipeline",
        "codepipeline:ListTagsForResource"
      ],
      "Effect": "Allow",
      "Resource": "${aws_codepipeline.terraform_iam_codepipeline.arn}"
    },
    {
      "Sid": "CloudwatchLogsManagement",
      "Action": [
        "logs:CreateLogDelivery",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DeleteLogDelivery",
        "logs:DeleteLogGroup",
        "logs:DeleteLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:PutRetentionPolicy"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBLockAccess",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:UpdateItem"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:us-east-1:account:table/terraform-table-lock"
    },
    {
      "Sid": "EC2FullAccess",
      "Action": "ec2:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "SSMFullAccess",
      "Action": "ssm:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchAndEventsFullAccess",
      "Action": [
        "cloudwatch:*",
        "events:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "CloudFormationFullAccess",
      "Action": "cloudformation:*",
      "Effect": "Allow",
      "Resource": "*"      
    },
    {
      "Sid": "DynamoDBFullAccess",
      "Action": "dynamodb:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "RDSFullAccess",
      "Action": "rds:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "SNSFullAccess",
      "Action": "sns:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "SQSFullAccess",
      "Action": "sqs:*",
      "Effect": "Allow",
      "Resource": "*"
    },    
    {
      "Sid": "TagFullAccess",
      "Action": [
        "tag:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "terraform_iam_codebuild_project" {
  name          = "terraform_iam_codebuild_project"
  description   = "Codebuild project to run terraform IAM related code"
  build_timeout = "60"
  service_role  = aws_iam_role.terraform_iam_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
  }

  tags = {
      env = var.env,
      Provisioner = var.provisioner,
      owner = var.owner,
      project = var.project
  }
}

resource "aws_s3_bucket" "terraform_iam_artifact_bucket" {
  bucket = "terraform-iamusers-med-artifact-bucket"
  acl    = "private"
  force_destroy = true

  tags = {
      env = var.env,
      Provisioner = var.provisioner,
      owner = var.owner,
      project = var.project
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_artifact_bucket" {
  bucket = aws_s3_bucket.terraform_iam_artifact_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# CodePipeline Policies

resource "aws_iam_role" "terraform_iam_codepipeline_role" {
  name = "terraform_iam_codepipeline_role"
  
  tags = {
      env = var.env,
      Provisioner = var.provisioner,
      owner = var.owner,
      project = var.project
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "codepipeline_terraform_role_policy" {
   name        = "codepipeline_terraform_policy"
   role = aws_iam_role.terraform_iam_codepipeline_role.id

   policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3CodePipelineAccess",
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "CodeBuildCodePipelineAccess",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:BatchGetProjects",
        "codebuild:StartBuild",
        "codebuild:StopBuild"
      ],
      "Effect": "Allow",
      "Resource": "${aws_codebuild_project.terraform_iam_codebuild_project.arn}"
    },
    {
      "Sid": "CodeCommitAccess",
      "Action": [
        "codecommit:BatchGetCommits",
        "codecommit:BatchGetRepositories",
        "codecommit:GetBranch",
        "codecommit:GetComment",
        "codecommit:GetCommit",
        "codecommit:UploadArchive",
        "codecommit:GetRepository",
        "codecommit:GitPull",
        "codecommit:ListBranches",
        "codecommit:GetUploadArchiveStatus"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:codecommit:us-east-1:account:aws-iam-selfservice"
    },
    {
      "Sid": "CloudWatchFullAccess",
      "Action": "cloudwatch:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "SNSFullAccess",
      "Action": "sns:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "SQSFullAccess",
      "Action": "sqs:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "PassRole",
      "Action": [
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
 }

resource "aws_codepipeline" "terraform_iam_codepipeline" {
  name     = "terraform_iam_codepipeline"
  role_arn = aws_iam_role.terraform_iam_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.terraform_iam_artifact_bucket.bucket
    type     = "S3"
  }
  
  tags = {
      env = var.env,
      Provisioner = var.provisioner,
      owner = var.owner,
      project = var.project
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = var.repo_name
        BranchName = var.repo_branch
      }
    }
  }

  stage {
    name = "Build_Create_Infra"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_iam_codebuild_project.name
      }
    }
  }
}

### Code for Cloud Custodian Resources Pipeline and Build


resource "aws_iam_role" "terraform_custodian_codebuild_role" {
  name = "terraform_custodian_codebuild_role"
  
  tags = {
      env = var.env,
      Provisioner = var.provisioner,
      owner = var.owner,
      project = var.project
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "terraform_custodian_codebuild_role_policy" {
  name = "terraform-custodian-codebuild-role-policy"
  role = aws_iam_role.terraform_custodian_codebuild_role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "FullLambdaAccess",
      "Action": "lambda:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "IamPassRole",
      "Action": "iam:PassRole",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "FullTaggingAccess",
      "Action": "tag:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "EC2FullAccess",
      "Action": "ec2:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "RDSFullAccess",
      "Action": "rds:*",
      "Effect": "Allow",
      "Resource": "*"
    },    
    {
      "Sid": "S3CodePipelineAccess",
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "kmsCodePipelineFullAccess",
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "CodeBuildFullAccessOnSelf",
      "Action": "codebuild:*",
      "Effect": "Allow",
      "Resource": "${aws_codebuild_project.terraform_custodian_codebuild_project.id}"
    },
    {
      "Sid": "CodePipelineAccesss",
      "Action": [
        "codepipeline:GetPipeline",
        "codepipeline:ListTagsForResource"
      ],
      "Effect": "Allow",
      "Resource": "${aws_codepipeline.terraform_custodian_codepipeline.arn}"
    },
    {
      "Sid": "CloudwatchLogsManagement",
      "Action": [
        "logs:CreateLogDelivery",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DeleteLogDelivery",
        "logs:DescribeLogStreams",
        "logs:DeleteLogGroup",
        "logs:DeleteLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:PutRetentionPolicy"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "CWEventsPermissions",
      "Effect": "Allow",
      "Action": [
        "events:ActivateEventSource",
        "events:DeleteRule",
        "events:DescribeEventSource",
        "events:DescribeRule",
        "events:DisableRule",
        "events:EnableRule",
        "events:ListEventSources",
        "events:ListRules",
        "events:ListTagsForResource",
        "events:ListTargetsByRule",
        "events:PutEvents",
        "events:PutPermission",
        "events:PutRule",
        "events:PutTargets",
        "events:RemovePermission",
        "events:RemoveTargets",
        "events:TagResource",
        "events:TestEventPattern",
        "events:UntagResource"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "terraform_custodian_codebuild_project" {
  name          = "terraform_custodian_codebuild_project"
  description   = "Codebuild project to run terraform cloud custodian related code"
  build_timeout = "60"
  service_role  = aws_iam_role.terraform_custodian_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
  }

  tags = {
      env = var.env,
      Provisioner = var.provisioner,
      owner = var.owner,
      project = var.project
  }
}

resource "aws_iam_role" "terraform_custodian_codepipeline_role" {
  name = "terraform_custodian_codepipeline_role"
  
  tags = {
      env = var.env,
      Provisioner = var.provisioner,
      owner = var.owner,
      project = var.project
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "codepipeline_custodian_terraform_role_policy" {
   name        = "codepipeline_custodian_terraform_role_policy"
   role        = aws_iam_role.terraform_custodian_codepipeline_role.id

   policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3CodePipelineAccess",
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "CodeBuildCodePipelineAccess",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:BatchGetProjects",
        "codebuild:StartBuild",
        "codebuild:StopBuild"
      ],
      "Effect": "Allow",
      "Resource": "${aws_codebuild_project.terraform_custodian_codebuild_project.arn}"
    },
    {
      "Sid": "CodeCommitAccess",
      "Action": [
        "codecommit:BatchGetCommits",
        "codecommit:BatchGetRepositories",
        "codecommit:GetBranch",
        "codecommit:GetComment",
        "codecommit:GetCommit",
        "codecommit:UploadArchive",
        "codecommit:GetRepository",
        "codecommit:GitPull",
        "codecommit:ListBranches",
        "codecommit:GetUploadArchiveStatus"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:codecommit:us-east-1:account:${var.custodian_repo_name}"
    },
    {
      "Sid": "CloudWatchFullAccess",
      "Action": "cloudwatch:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "SNSFullAccess",
      "Action": "sns:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "SQSFullAccess",
      "Action": "sqs:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "PassRole",
      "Action": [
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
 }

resource "aws_codepipeline" "terraform_custodian_codepipeline" {
  name     = "terraform_custodian_codepipeline"
  role_arn = aws_iam_role.terraform_custodian_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.terraform_iam_artifact_bucket.bucket
    type     = "S3"
  }
  
  tags = {
      env = var.env,
      Provisioner = var.provisioner,
      owner = var.owner,
      project = var.project
  }

  stage {
    name = "Custodian_Rules_Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = var.custodian_repo_name
        BranchName = var.repo_branch
      }
    }
  }

  stage {
    name = "Build_Create_Custodian_Rules"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_custodian_codebuild_project.name
      }
    }
  }
}
