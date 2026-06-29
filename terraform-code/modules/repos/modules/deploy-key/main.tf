variable "repo_name" {
  description = "Name of the repo that needs a key."
  type        = string
}

resource "tls_private_key" "this" {
  algorithm = "ED25519"

}

resource "github_repository_deploy_key" "this" {
  title      = "${var.repo_name}-key"
  repository = "tfatoz-prod-repo-infra"
  key        = tls_private_key.this.public_key_openssh
  read_only  = true
}

resource "local_file" "this" {
  content  = tls_private_key.this.private_key_openssh
  filename = "${path.cwd}/${github_repository_deploy_key.this.title}.pem"

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${self.filename}"
  }

}