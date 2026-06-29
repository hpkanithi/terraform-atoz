data "terraform_remote_state" "repos" {
  backend = "remote"
  config = {
    organization = "hpk-hpc-16"
    workspaces = {
      name = "hpk-hpc-16"
    }
  }
}

locals {
  repos = { for k,v in data.terraform_remote_state.repos.outputs.clone_urls["prod"].clone-urls : k => v}
}

resource "github_repository" "info" {
  name        = "tfatoz_info_page"
  description = "Repo info for info-page"
  visibility  = "public"
  auto_init   = true
  pages {
    # for_each = each.value.page ? [] : []
    # content {
    source {
      branch = "main"
      path   = "/"
    }
    # }
  }

  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo view ${self.name} --web" : "echo 'skip repo view'"
  }

}

data "github_user" "current" {
  username = ""
}

resource "time_static" "this" {}

resource "github_repository_file" "this" {
  repository = github_repository.info.name
  branch     = "main"
  file       = "index.md"
  content = templatefile("${path.module}/templates/index.tftpl", {
    avatar = data.github_user.current.avatar_url,
    name   = data.github_user.current.name,
    date   = time_static.this.year
    repos  = var.repos
  })
  overwrite_on_create = true
}
