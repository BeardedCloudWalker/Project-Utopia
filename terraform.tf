provider "aws" {
    profile  = "${var.aws["profile"]}"
    region   = "${var.aws["region"]}"
}
terraform {
    backend "s3" {
        bucket="${var.backend_state_bucket}"
        key="${var.backend_state_key}"
        region="${var.aws["region"]}"
    }
}