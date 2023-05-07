output "ecr_repositories" {
  value = {
    for repo in aws_ecr_repository.ecr_repository : "${repo.name}" => repo.repository_url
  }
}
