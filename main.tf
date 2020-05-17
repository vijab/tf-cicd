data "aws_region" "current" {}

locals {
  codebuild_s3_bucket_name = join("-", [var.repo_name, var.repo_branch])
}

resource "aws_s3_bucket" "codebuild_s3_bucket" {
  bucket = local.codebuild_s3_bucket_name
  versioning {
    enabled = true
  }
}

resource "aws_codebuild_project" "codebuild_docker_image" {
  name = "${var.ecs_image_name}_image"
  build_timeout = "300"
  service_role = aws_iam_role.cicd_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:1.0"
    type = "LINUX_CONTAINER"
    privileged_mode = "true"
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecs_image_name
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

resource "aws_ecr_repository" "image_repository" {
  name                 = var.ecs_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_codepipeline" "build_and_deploy" {
  name = "${var.ecs_image_name}_deployment"
  role_arn = aws_iam_role.cicd_role.arn
  artifact_store {
    location = aws_s3_bucket.codebuild_s3_bucket.bucket
    type = "S3"
  }
  stage {
    name = "Source"
    action {
      category = "Source"
      name = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"
      output_artifacts = ["code"]

      configuration = {
        OAuthToken           = var.github_oauth_token
        Owner                = var.github_repo_owner
        Repo                 = var.repo_name
        Branch               = var.repo_branch
        PollForSourceChanges = var.poll_source_changes
      }
    }
  }

  stage {
    name = "BuildDockerImage"
    action {
      category = "Build"
      name = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["code"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_docker_image.name
      }
    }
  }
}