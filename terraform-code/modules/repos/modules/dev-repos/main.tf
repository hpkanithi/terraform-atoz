# resource "random_id" "random" {
#   byte_length = 2
#   count       = var.repo_count
# }

resource "github_repository" "tfatoz_repo" {
  # count       = var.repo_count
  for_each    = var.repos
  name        = "tfatoz-${var.env}-repo-${each.key}"
  description = "${each.value.lang} Code for something"
  visibility  = var.env == "dev" ? "private" : "public"
  auto_init   = true
  dynamic "pages" {
    for_each = each.value.pages ? [1] : []
    content {
      source {
        branch = "main"
        path   = "/"
      }
    }
  }


  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo view ${self.name} --web" : "echo 'skip repo view'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${self.name}"
  }
}

resource "terraform_data" "repo-clone" {
  for_each   = var.repos
  depends_on = [github_repository_file.readme, github_repository_file.main]

  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo clone ${github_repository.tfatoz_repo[each.key].name}" : "echo 'skip clone'"
  }
}

resource "github_repository_file" "readme" {
  # count               = var.repo_count
  for_each   = var.repos
  repository = github_repository.tfatoz_repo[each.key].name
  branch     = "main"
  file       = "README.md"
  content = templatefile("${path.module}/templates/readme.tftpl", {
    env  = var.env,
    lang = each.value.lang,
    repo = each.key,
    name = data.github_user.current.name
  })
  # content             = <<-EOT
  #                         # This is a ${var.env} ${each.value.lang} repo for ${each.key} developers.
  #                         The infra was last modified by: ${data.github_user.current.name}.
  #                         EOT}
  overwrite_on_create = true

  # lifecycle {
  #   ignore_changes = [
  #     content,
  #   ]
  # }

}

resource "github_repository_file" "main" {
  # count               = 2
  for_each            = var.repos
  repository          = github_repository.tfatoz_repo[each.key].name
  branch              = "main"
  file                = each.value.filename
  content             = "Hello ${each.value.lang} Developers!"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      content,
    ]
  }
}

# moved {
#   from = github_repository_file.index
#   to   = github_repository_file.main
# }
