terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
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
  counter-table-name = module.db.metrics_table_name
  api_gateway_execution_arn=module.api-gw.api-gw-exec-arn
}

module "content-s3"{
  source = "./modules/s3"
  bucket_name=var.content-bucket-name
}

module "cloud-front-api" {
  source = "./modules/cloud-front-api"
  api-id = element(split("/",module.api-gw.api-gw-arn), 2)
}

module "cloud-front-web" {
  source = "./modules/cloud-front-web"
  content_bucket_name=var.content-bucket-name
  hz_name=var.hosted-zone-name
  hosted_zone_id=var.hosted-zone-id
  rec_prefix = var.rec-prefix
  bucket_reg_domain_name=module.content-s3.bucket_reg_domain_name
  bucket_arn=module.content-s3.bucket_arn
  cert_arn = var.cert_arn
}
