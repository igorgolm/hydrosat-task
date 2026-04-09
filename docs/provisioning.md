# How to Provision

This guide walks you through setting up the entire platform from scratch.

## Prerequisites

Before starting, ensure you have the following installed on your machine:
- [AWS CLI](https://aws.amazon.com/cli/): Configured with appropriate credentials.
- [OpenTofu](https://opentofu.org/): For infrastructure provisioning.
- [Task](https://taskfile.dev/): The task runner we use to orchestrate commands.
- [kubectl](https://kubernetes.io/docs/tasks/tools/): For interacting with the EKS cluster.
- [terraform-docs](https://terraform-docs.io/): For generating documentation.

## Daily Operations (Taskfile)

The project uses [Taskfile](https://taskfile.dev/) to simplify operations. From the root directory, you can run:
```bash
task init -- <layer> <env>    # Initialize a layer
task plan -- <layer> <env>    # Plan and verify changes
task apply -- <layer> <env>   # Deploy the layer
task destroy -- <layer> <env> # Destroy the layer
```
*Valid layers: check `stacks/` directory*

## Sequences of Deployment

Our infrastructure relies on a layered "Stack" architecture. You must provision the layers in order, as higher layers depend on the outputs of lower layers. We use `Taskfile` to simplify this running `task apply -- <layer> <environment>`.

> [!CAUTION]
> Ensure you are authenticated with AWS (e.g., via `aws sso login` or exporting access keys) before running these commands.

### Step 0: Bootstrap Layer (State Management)
Before deploying any platform components, we must create the backend infrastructure to store our OpenTofu states securely. The built-in bootstrap stack (`stacks/aws/bootstrap`) provisions an Amazon S3 bucket for state storage and a DynamoDB table for state locking (to prevent concurrent modification).

```bash
# Initialize locally
task bootstrap-init

# Create the S3 bucket, DynamoDB table, and KMS key
task bootstrap-apply

# Migrate the bootstrap local state into the newly created S3 bucket
task bootstrap-migrate
```

### Step 1: Networking Layer
Provisions the VPC and Subnets.
```bash
task apply -- networking dev
```

### Step 2: Compute Layer
Provisions the EKS Cluster. **This step takes approximately 15-20 minutes.**
```bash
task apply -- compute dev
```
*After completion, update your local kubeconfig to interact with the new cluster:*
```bash
aws eks update-kubeconfig --region eu-north-1 --name <cluster-name>
```

### Step 3: Database Layer
Provisions the RDS PostgreSQL instance and configures AWS Secrets Manager.
```bash
task apply -- database dev
```

### Step 4: Dagster Layer
Deploys the Dagster orchestration platform to the EKS cluster via Helm.
```bash
task apply -- dagster dev
```

## Teardown

To destroy the infrastructure, reverse the order:
```bash
task destroy -- dagster dev
task destroy -- database dev
task destroy -- compute dev
task destroy -- networking dev
```
