# CloudNorth Infrastructure

This is a portfolio project where I built production-grade AWS infrastructure from scratch using Terraform. The goal was to go beyond tutorials and build something that reflects how infrastructure actually works at a company — VPC, load balancer, containerised app on ECS Fargate, PostgreSQL on RDS, secrets handled properly, and no manual clicking in the AWS console.

The fictional company is CloudNorth, a Canadian e-commerce platform. The infrastructure runs in us-east-1 across two availability zones.

---

## What gets built

A three-tier AWS architecture:

- **Public layer** — Application Load Balancer sits here, exposed to the internet
- **Private app layer** — ECS Fargate tasks run here, not reachable directly from outside
- **Private data layer** — RDS PostgreSQL lives here, only the app layer can talk to it

Everything is wired together so traffic flows: internet → ALB → ECS tasks → RDS. Nothing bypasses the layers.

---

## Architecture

```
Internet
    │
    ▼
Application Load Balancer (public subnets, us-east-1a + 1b)
    │
    ▼
ECS Fargate (private app subnets, us-east-1a + 1b)
    │
    ▼
RDS PostgreSQL (private data subnets, us-east-1a + 1b)
```

Supporting pieces:
- ECR stores the Docker images
- Secrets Manager holds the RDS password, ECS injects it at task startup so it never touches the code or Terraform state
- S3 stores ALB access logs and app assets
- IAM roles follow least privilege — execution role for ECS to pull images and write logs, task role for the running container to access S3
- VPC endpoints for ECR, Secrets Manager, CloudWatch Logs, and S3 so private tasks never need a NAT gateway to reach AWS services
- Auto scaling on ECS, scales out at 60% CPU, scales in at 30%
- CloudWatch log group per environment for container logs

---

## Project structure

```
cloudnorth-project/
├── main.tf                     # wires all modules together
├── providers.tf                # AWS provider, S3 remote state backend
├── variables.tf                # root variable declarations
├── outputs.tf                  # ALB DNS, cluster name, log group
├── terraform.tfvars            # your values, gitignored
├── terraform.tfvars.example    # safe template to copy from
│
├── app/                        # test Node.js app to validate the stack
│   ├── app.js                  # HTTP server with /health, /, /db routes
│   ├── Dockerfile
│   └── package.json
│
├── modules/
│   ├── networking/             # VPC, subnets, IGW, route tables
│   ├── security_groups/        # SG rules per tier, kept separate from SG definitions
│   ├── ecr/                    # container registries
│   ├── iam/                    # execution role and task role
│   ├── s3/                     # app assets bucket and ALB logs bucket
│   ├── alb/                    # load balancer, target group, listeners
│   ├── database/               # RDS PostgreSQL with managed password
│   ├── ecs/                    # Fargate cluster, task definition, service, auto scaling
│   └── vpc_endpoints/          # private connectivity to AWS services
│
└── docs/
    └── restructure-guide.md    # guide to split this into per-environment state files
```

---

## State management

Remote state is stored in S3 with native S3 locking (Terraform 1.10+, `use_lockfile = true`). No DynamoDB needed.

The S3 bucket is created separately in a bootstrap project that lives outside this repo. It has to exist before you can run `terraform init` here. That's intentional — you don't want your state bucket managed by the same state it's storing.

State file location: `dev/terraform.tfstate` in the bucket defined in `providers.tf`.

---

## The test app

The `app/` folder has a minimal Node.js HTTP server. Three routes:

- `GET /health` — returns 200, used by the ALB health check
- `GET /` — returns app name, environment, region
- `GET /db` — connects to RDS and runs a simple query, confirms the full stack is working

The app reads database credentials from environment variables. The password comes from Secrets Manager via ECS secrets injection — it's never in the code or in any config file.

---

## Prerequisites

- Terraform 1.10 or higher
- AWS CLI with a configured default profile
- Docker (to build and push the app image to ECR)
- The bootstrap S3 bucket already created

---

## Getting started

Copy the example vars and fill in your account-specific values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Initialise and apply:

```bash
terraform init
terraform plan
terraform apply
```

After apply, the ALB DNS name is printed as an output. The app runs on port 8080:

```bash
curl http://<alb_dns_name>:8080/health
curl http://<alb_dns_name>:8080/db
```

---

## Pushing the app image to ECR

Build and push before running `terraform apply` for ECS:

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-east-1.amazonaws.com

docker build -t dev-api-app ./app

docker tag dev-api-app:latest \
  <account_id>.dkr.ecr.us-east-1.amazonaws.com/dev-api-app:latest

docker push \
  <account_id>.dkr.ecr.us-east-1.amazonaws.com/dev-api-app:latest
```

---

## Things intentionally left out

**NAT Gateway** — costs about $32/month. Private tasks reach AWS services through VPC endpoints instead. For a real production setup you'd want NAT for general internet egress from private subnets.

**HTTPS** — port 443 redirects are wired up in the ALB but there's no ACM certificate attached. In production you'd use ACM with a real domain.

**Multi-environment split state** — the current setup uses one state file. The `docs/restructure-guide.md` walks through converting this to a directory-based layout where networking, database, and compute each have their own state file per environment.

---

## Rules

Never create resources manually in the AWS console. If it is not in Terraform it does not exist. Never commit `terraform.tfvars` — it is in `.gitignore` for a reason.
