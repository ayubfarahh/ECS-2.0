# ecsv2 — URL Shortener on AWS ECS

A production-grade URL shortener built with FastAPI, deployed on AWS ECS Fargate with blue/green deployments, Terraform-managed infrastructure, and a GitHub Actions CI/CD pipeline.

---

## Overview

This project provisions and deploys a containerised URL shortener service to AWS. Short URLs are stored in DynamoDB and resolved via redirect. The service runs on ECS Fargate behind an HTTPS Application Load Balancer, with WAF protection and blue/green deployments via CodeDeploy.


### Architecture


![alt text!](/img/v2.png)


## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) with `amazon.aws` and `community.aws` collections
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with appropriate credentials
- [Docker](https://docs.docker.com/get-docker/)
- An AWS account with a hosted zone for your domain in Route53
- An ACM certificate issued for your domain

---

## Setup & Deployment

### 1. Bootstrap (one-time)

Creates the S3 bucket for Terraform state and the ECR repository.

```bash
cd ansible
ansible-playbook bootstrap-playbook.yaml
```

### 2. Build & Push the Docker Image

The GitHub Actions workflow (`.github/workflows/build.yaml`) handles this automatically on manual trigger. To run it locally:

```bash
aws ecr get-login-password --region eu-west-2 | \
  docker login --username AWS --password-stdin <account_id>.dkr.ecr.eu-west-2.amazonaws.com

docker build -t ecsv2 ./app
docker tag ecsv2:latest <account_id>.dkr.ecr.eu-west-2.amazonaws.com/ecsv2:latest
docker push <account_id>.dkr.ecr.eu-west-2.amazonaws.com/ecsv2:latest
```

### 3. Provision Infrastructure

```bash
cd infra
terraform init
terraform apply -var="ecr_image_url=<account_id>.dkr.ecr.eu-west-2.amazonaws.com/ecsv2:latest"
```

### 4. Deploy a New Version

Deployments use CodeDeploy's **canary strategy** (10% traffic shifted first, then 100% after 5 minutes). To trigger a deployment, update `infra/task-def.json` with the new image tag and run a CodeDeploy deployment via the AWS Console or CLI.

Auto-rollback is enabled on deployment failure.


**Shorten a URL:**

```bash
curl -X POST https://ecsv2.ayubs.uk/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

```json
{"short": "a1b2c3d4", "url": "https://example.com"}
```

---

## CI/CD

The GitHub Actions workflow uses **OIDC** (no long-lived AWS keys) to assume an IAM role and push images to ECR. It is triggered manually via `workflow_dispatch`.

To use it, ensure the `github-actions-role` IAM role in your AWS account has the correct trust policy for your repository (configured in `infra/modules/iam/main.tf`).

---

