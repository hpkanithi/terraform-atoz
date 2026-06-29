variable "repo_max" {
  type        = number
  description = "Number of repos"
  default     = 1

  validation {
    condition     = var.repo_max <= 10
    error_message = "Do not deploy more than 10 repos"
  }
}

variable "env" {
  type        = string
  description = "Environments"

  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "The environments must be 'dev' or 'prod'"
  }
}

variable "repos" {
  type        = map(map(string))
  description = "Repo names"

  validation {
    condition     = length(var.repos) <= var.repo_max
    error_message = "No extra repos"
  }
}

variable "run_provisioners" {
  type    = bool
  default = false
}
