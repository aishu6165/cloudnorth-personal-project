# CloudNorth Infrastructure

Terraform infrastructure for the CloudNorth e-commerce platform hosted on AWS. This repo covers everything from networking to compute, database, and observability — built and deployed block by block.

## What This Builds

A multi-tier AWS architecture in us-east-1 across two availability zones. The network is split into three layers — public subnets for the load balancer, private app subnets for ECS Fargate containers, and private data subnets for the RDS database. Nothing in the private layers is directly reachable from the internet.

## Prerequisites

You need Terraform 1.7 or higher, an AWS account with a configured default profile, and the AWS CLI installed. The S3 state backend and DynamoDB lock table must exist before running any Terraform commands — see the bootstrap setup below.

## State Backend

Remote state is stored in S3 with native S3 locking. The backend is configured in `providers.tf`. The S3 bucket and lock setup live in a separate bootstrap project outside this repo and are created once manually.

## Getting Started

Copy the example vars file and fill in your values.

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then initialise and apply.

```bash
terraform init
terraform plan
terraform apply
```

## Project Structure

```
cloudnorth-project/
├── main.tf               # Root module — wires all modules together
├── providers.tf          # AWS provider and S3 backend config
├── variables.tf          # Root variable declarations
├── terraform.tfvars      # Your local variable values (gitignored)
├── terraform.tfvars.example  # Safe template to commit
└── modules/
    ├── networking/       # VPC, subnets, internet gateway, route tables
    ├── security_groups/  # Security group rules per tier
    ├── ecr/              # Container registries
    ├── ecs/              # Fargate cluster, services, task definitions
    ├── alb/              # Application load balancer and listeners
    ├── database/         # RDS PostgreSQL
    ├── s3/               # App assets and log buckets
    ├── iam/              # Roles and policies
    ├── secret_manager/   # Secrets Manager entries
    └── monitoring/       # CloudWatch dashboards and alarms
```

## Tagging

Every resource is tagged with Project, Environment, ManagedBy, Owner, and CostCentre. Default tags applied via the AWS provider cover ManagedBy and Project. Environment-specific tags are set per module.

## Important Notes

Never create resources manually in the AWS console. If it is not in Terraform it does not exist. Never commit terraform.tfvars or any file containing credentials or passwords.
