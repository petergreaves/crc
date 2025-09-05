# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cloud-resume-challenge"
}
variable "content-bucket-name" {
  description = "The content bucket's name"
  type        = string
  default     = "cloud-resume-challenge-content-bucket"
}
variable "rec-prefix" {
  type    =  string
  default = "about"
}
variable "hosted-zone-name" {
  description = "The hosted zone"
  type        = string
  default     = "peter-greaves.net"
}

variable "hosted-zone-id" {
  description = "The hosted zone id"
  type        = string
  default     = "Z0738660KJJM7N1VV5WV"
}

variable "domain_name" {
  description = "the domain name of the site"
  type = string
  default="about.peter-greaves.net"
}
variable "cert_arn"{
  description = "the SSL cert referenced in the cloud front configuration"
  type = string
  default="arn:aws:acm:us-east-1:869700439563:certificate/0736b2dc-093f-4a60-bacb-e28e70414a25"
}
variable "access-control-allow-origin-url" {
  description = "the URL for the CORS Access contrpl allowed origin in lambda"
  type = string
  default="https://about.peter-greaves.net"
}

