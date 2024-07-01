resource "aws_ecr_repository" "pep-restaurant-ms-manager" {
  name                 = "pep-restaurant-ms-manager"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}