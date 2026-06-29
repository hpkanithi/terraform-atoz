# terraform {
#   backend "local" {
#     path = "../state/terraform.tfstate"
#   }
# }

terraform {
  required_version = ">= 1.15.0, < 1.16.0"

  cloud {
    
    organization = "hpk-hpc-16"

    workspaces {
      name = "dev"
    }
  }
}
