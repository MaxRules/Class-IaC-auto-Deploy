terraform {
  backend "s3" {
    bucket = "vegeta-over-9000-tfstate"
    key    = "terraform/statefile.tfstate"
    region = "us-east-2"
  }
}
