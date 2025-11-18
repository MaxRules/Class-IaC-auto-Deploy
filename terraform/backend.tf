terraform {
  backend "s3" {
    bucket = "automation-2025-tfstate"
    key    = "terraform/statefile.tfstate"
    region = "us-east-2"
  }
}
