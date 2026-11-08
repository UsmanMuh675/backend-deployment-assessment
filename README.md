# MuchToDo Backend – AWS Deployment Assessment

## Project Overview

This project provisions AWS infrastructure using Terraform and deploys the MuchToDo Golang backend application using Docker and Docker Compose.

The backend connects to MongoDB and is exposed through an AWS Application Load Balancer (ALB).

## Architecture

The deployment includes:

- AWS VPC (`10.0.0.0/16`)
- Two public subnets across different Availability Zones
- Two private subnets across different Availability Zones
- Internet Gateway and NAT Gateway
- Bastion EC2 instance
- Backend EC2 instance
- MongoDB EC2 infrastructure provisioned by Terraform
- Application Load Balancer
- Target Group and HTTP listener
- Security Groups
- Dockerized Golang backend
- MongoDB Docker service with persistent volume

## Repository Structure

```text
backend-deployment-assessment/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── user_data/
│       ├── backend_setup.sh
│       └── mongodb_setup.sh
├── Dockerfile
├── docker-compose.yaml
├── .dockerignore
├── .gitignore
├── evidence/
└── README.md
```

## Prerequisites

Install the following tools:

- AWS account
- AWS CLI
- Terraform
- Docker
- Docker Compose
- Git
- SSH client

Configure AWS credentials before provisioning:

```bash
aws configure
```

## Phase 1: Infrastructure Provisioning

Navigate to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Preview the infrastructure:

```bash
terraform plan -out=tfplan
```

Apply the configuration:

```bash
terraform apply tfplan
```

Display the infrastructure outputs:

```bash
terraform output
```

## Phase 2: Docker Configuration

Navigate to the application directory on the backend EC2 instance:

```bash
cd ~/much-to-do/Server/MuchToDo
```

Create the environment configuration file:

```bash
nano .env
```

Configure the required application variables, including MongoDB credentials, MongoDB URI, database name, port, and JWT secret.

Do not commit `.env` or expose credentials in GitHub.

Build and start the application:

```bash
docker compose up -d --build
```

Check the running containers:

```bash
docker compose ps
```

View backend logs:

```bash
docker logs --tail 50 muchtodo-backend
```

## Phase 3: Deployment Verification

Check the backend health endpoint locally:

```bash
curl -i http://localhost:8080/health
```

Expected response:

```json
{
  "cache": "disabled",
  "database": "ok"
}
```

Check the application through the Application Load Balancer:

```bash
curl http://YOUR-ALB-DNS-NAME/
```

Check the health endpoint through the ALB:

```bash
curl http://YOUR-ALB-DNS-NAME/health
```

Replace `YOUR-ALB-DNS-NAME` with the actual ALB DNS name.

## Security Considerations

- Backend SSH access is restricted to the Bastion Security Group.
- Backend application traffic is allowed from the ALB Security Group.
- MongoDB access is restricted to the backend.
- MongoDB credentials and JWT secrets are stored outside version control.
- Terraform state and sensitive variable files must not be committed to GitHub.

## Evidence

The `evidence/` directory contains screenshots demonstrating:

- Terraform initialization and planning
- AWS VPC and subnet configuration
- Security Groups
- EC2 instances
- Application Load Balancer and Target Group
- Docker image build
- Docker Compose services
- Backend health checks
- SSH access through the Bastion host
- Application response through the ALB

## Cleanup

To remove Terraform-managed infrastructure when it is no longer required:

```bash
cd terraform
terraform destroy
```

Review the destruction plan and confirm before proceeding.

To stop the Docker services on the backend EC2 instance:

```bash
docker compose down
```

**Warning:** Terraform destroy and Docker volume removal can permanently remove infrastructure and data. Back up anything important before cleanup.

## Author

**Usman Muhammed**

Cloud Engineering Baraka 2026 – Month 1 Assessment

GitHub: https://github.com/UsmanMuh675
