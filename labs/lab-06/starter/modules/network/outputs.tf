output "vpc_id" {
  description = "ID of the simulated VPC"
  value       = terraform_data.vpc.id
}

output "subnet_cidrs" {
  description = "Private subnet CIDRs"
  value       = [for s in terraform_data.subnet : s.input.cidr]
}
