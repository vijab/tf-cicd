#-START---Common Github Properties
variable "github_oauth_token" {
  type = "string"
}

variable "github_repo_owner" {
  type = "string"
}
#-END---Common Github Properties

#-START---ECS Related Properties
variable "ecs_repo_name" {
  type = "string"
}

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

