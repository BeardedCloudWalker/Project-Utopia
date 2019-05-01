provider "aws" {
    profile  = "${var.aws["profile"]}"
    #access_key = "${var.aws["aws_access_key"]}"
    #secret_key = "${var.aws["aws_secret_key"]}"
    region   = "${var.aws["region"]}"
    access_key = "AKIAYD53B5EONNO27YXO"
    secret_key = "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"
}
terraform {
    backend "s3" {
    }
}