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
