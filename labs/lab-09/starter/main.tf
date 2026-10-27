# Lab 09 starter — CONCEPTUAL. Do NOT run against a real account without
# reading the README safety section and explicitly agreeing with your instructor.

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

# Scenario: during an incident, someone created this bucket and log group by hand.
#   S3 bucket:      jk-incident-artifacts-2026
#   Log group:      /aws/lambda/orders-api
# Your task: bring both under Terraform management WITHOUT recreating them.

# TODO (Task 2): add import blocks here

# TODO (Task 5): after generating config, move the cleaned-up resource blocks here
