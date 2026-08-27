
resource "aws_ecr_repository" "discreta_ecr" {
  name                 = "discreta"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
