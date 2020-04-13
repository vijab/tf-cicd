resource "aws_codebuild_project" "codebuild_docker_image" {
  name = "${var.ecs_image_name}_image"
  build_timeout = "300"
  service_role = "${var.iam_code_build_role_arn}"
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
      value = "${var.ecs_image_name}"
    }
  }
  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

resource "aws_codepipeline" "build_and_deploy" {
  name = "${var.ecs_image_name}_deployment"
  role_arn = "${var.iam_code_deploy_role_arn}"
  artifact_store {
    location = "${var.s3_code_build_bucket}"
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
        OAuthToken           = "${var.github_oauth_token}"
        Owner                = "${var.github_repo_owner}"
        Repo                 = "${var.repo_name}"
        Branch               = "${var.repo_branch}"
        PollForSourceChanges = "${var.poll_source_changes}"
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
        ProjectName = "${aws_codebuild_project.codebuild_docker_image.name}"
      }
    }
  }
}
