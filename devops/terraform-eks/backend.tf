
terraform {
  required_version = "~> 1.3.6"
  backend "s3" {
    bucket         = "cm-tf-backend"
    dynamodb_table = "cm-terraform-backend"
    key            = "terraform.tfstate"
    region         = "us-west-1"
    encrypt        = true
  }
}