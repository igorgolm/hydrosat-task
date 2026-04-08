# HydroSat Data Platform

This repository contains all the conceptual and operational guides needed to understand, provision, and use the platform.
The infrastructure is built using **OpenTofu/Terraform** and organized according to a strict **Stacks & Layers** architecture.

## Directory Layout (Root)
```text
.
├── envs/               # Environment-specific variables (*.tfvars)
├── stacks/             # Infrastructure layers (OpenTofu)
│   ├── aws/            # AWS-specific infrastructure
│   │   ├── bootstrap/  # S3/DynamoDB for remote state
│   │   ├── networking/ # VPC, Subnets, NAT
│   │   ├── database/   # RDS Aurora/PostgreSQL
│   │   └── compute/    # EKS Cluster, Node Groups
│   └── k8s/            # Kubernetes applications & addons
│       └── dagster/    # Dagster workflow engine
├── Taskfile.yml        # Automation tool (task)
└── common_backend.hcl  # Shared S3 backend configuration
```

## Sections

- **[Infrastructure Design](docs/architecture.md)**
  An explanation of our architecture, network structure, and the justification for our core technological choices (Terraform/OpenTofu, EKS, Dagster, RDS).
- **[How to Provision](docs/provisioning.md)**
  A step-by-step guide to deploying the entire infrastructure from scratch.
- **[How to Use](docs/usage.md)**
  Instructions for accessing the deployed services, navigating the Dagster UI, API, and triggering jobs.
- **[How to Test](docs/testing.md)**
  A brief overview of our validation process, plan analysis, and naming convention audits to ensure the infrastructure integrity.
