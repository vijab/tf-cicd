#-START---Common Github Properties
variable "github_oauth_token" {
  type = "string"
  default = "generate-github-oauth-token-and-replace-here"
}

variable "github_repo_owner" {
  type = "string"
  default = "vijab"
}
#-END---Common Github Properties

#-START---Code Build Properties
variable "iam_code_build_role_arn" {
  description = "Role arn for the Code Build Role"
}
variable "iam_code_deploy_role_arn" {
  description = "Role arn for the Code Deploy Role"
}
variable "s3_code_build_bucket" {
  description = "S3 bucket to store intermediate builds."
}
#-END---Code Build Properties

#-START---ECS Related Properties
variable "ecs_image_name" {
  type = "string"
}
#-END---ECS Related Properties

#-START---Project Related Github Properties
variable "repo_name" {
  type = "string"
}

variable "repo_branch" {
  type = "string"
}

variable "poll_source_changes" {
  type = "string"
  default = "true"
}
#-END---Project Related Github Properties

