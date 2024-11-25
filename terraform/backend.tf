terraform {
  backend "s3" {
    bucket = "autonmis-bucket-eks"
    key    = "state/terraform-jaiditya.tfstate"
    region = "us-east-1"
  }
}
