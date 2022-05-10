terraform {
    required_version = "~>1.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~>3.0"
        }
        http = {
            source = "hashicorp/http"
            version = "2.1.0"
        }
        random = {
            source = "hashicorp/random"
            version = "3.1.0"
        }
    }
}
provider "aws" {
    region = "eu-central-1"
    profile = "tarikbaki3"
}
provider "http" {}
provider "random" {}