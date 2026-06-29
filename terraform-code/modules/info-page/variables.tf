# variable "repo" {
#   description = ""
#   type        = string
# }

variable "repos" {
  description = ""
  type        = map(any)
}

variable "run_provisioners" {
  type    = bool
  default = false
}