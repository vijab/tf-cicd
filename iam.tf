
data "aws_iam_policy_document" "cicd_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["codebuild.amazonaws.com", "codepipeline.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
    sid = "ServiceRoleCodeBuild"
  }
}

data "aws_iam_policy_document" "cicd_permissions" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning"
    ]
    resources = ["*"]
    effect = "Allow"
    sid = "AccessCodePipelineArtifacts"
  }
  statement {
    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]
    resources = ["*"]
    effect = "Allow"
    sid = "BuildCode"
  }
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["*"]
    effect = "Allow"
    sid = "AccessECR"
  }
  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
    effect = "Allow"
    sid = "AuthorizeECR"
  }
  statement {
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeServices",
      "ecs:CreateService",
      "ecs:ListServices",
      "ecs:UpdateService"
    ]
    resources = ["*"]
    effect = "Allow"
    sid = "AccessECS"
  }
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:*:*"]
    effect = "Allow"
    sid = "LogStream"
  }
}

resource "aws_iam_role" "cicd_role" {
  name = "cicd_role"
  permissions_boundary = ""
  assume_role_policy = data.aws_iam_policy_document.cicd_assume_policy.json
}

resource "aws_iam_role_policy" "iam_cicd_policy" {
  name = "iam_codepipeline_policy"
  role = aws_iam_role.cicd_role.id
  policy = data.aws_iam_policy_document.cicd_permissions.json
}
