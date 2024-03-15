
terraform {
  required_version = "~> 1.3.6"
  backend "s3" {
    bucket         = "cm-tf-ecs-backend"
    dynamodb_table = "cm-tf-ecs-backend"
    key            = "terraform.tfstate"
    region         = "us-west-1"
    encrypt        = true
  }
}