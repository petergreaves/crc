terraform {
   backend "remote" {
    organization = "cloud-work-peter-greaves64"
    workspaces {
      name = "cloud-resume-challenge"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
}

provider "aws" {
  region = var.aws-region
}


module "db"{
  source = "./modules/db"
}


module "api-gw"{
  source = "./modules/api-gw"
  counter-lambda-invoke-arn=module.lambda.invoke-arn
  counter-lambda-function-name=module.lambda.function-name
}

module "lambda"{
  source = "./modules/counter-lambda"
  counter-table-name = module.db.metrics-table-name
  api-gateway-execution-arn=module.api-gw.api-gw-exec-arn
  access-control-allow-origin-url=var.access-control-allow-origin-url
}

module "content-s3"{
  source = "./modules/s3"
  bucket_name=var.content-bucket-name
}

module "cloud-front-api" {
  source = "./modules/cloud-front-api"
  api-id = element(split("/",module.api-gw.api-gw-arn), 2)
  cert_arn = var.cert-arn
  domain_name=var.hosted-zone-name
}

module "cloud-front-web" {
  source = "./modules/cloud-front-web"
  content-bucket-name=var.content-bucket-name
  hz-name=var.hosted-zone-name
  hosted-zone-id=var.hosted-zone-id
  rec-prefix = var.rec-prefix
  bucket-reg-domain-name=module.content-s3.bucket-reg-domain-name
  bucket-arn=module.content-s3.bucket-arn
  cert-arn = var.cert-arn
}

module "api-hostname" {
  source = "./modules/api-hostname"
  domain-name=var.hosted-zone-name
  cf-api-domain-name = module.cloud-front-api.cloudfront-api-domain-name
  cf-api-hz-id       = module.cloud-front-api.cloudfront-api-hz-id
  hosted-zone-id=var.hosted-zone-id
}
