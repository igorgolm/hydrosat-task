# How to Use
This document outlines how to interact with the deployed Dagster platform, trigger pipelines, and utilize the API.

## EKS Cluster Access (kubectl)
For security reasons, the underlying Kubernetes control plane (EKS API endpoint) is also protected by an IP whitelist. If you cannot execute `kubectl` commands:
1. Open the compute layer configuration: `envs/dev/compute.tfvars`.
2. Locate the `public_access_cidrs` variable.
3. Add your current public IP to the list (e.g., `public_access_cidrs = ["<YOUR_IP>/32"]`).
4. Apply the changes: `task apply -- compute dev`.

## Accessing the Dagster UI (Important)

Because Dagster is deployed behind an AWS Application Load Balancer (ALB) with a custom environment hostname, you must configure your local machine before you can open the UI.

### 1. Local Network Resolution (/etc/hosts)
The AWS ALB uses a dynamic CNAME, but the Kubernetes Ingress controller expects requests explicitly for `dagster.dev.hydrosat.task`.
1. Retrieve your ALB address: `kubectl get ingress -n dagster` (Look for the `ADDRESS` column).
2. Resolve the underlying IP addresses: `nslookup <ALB_ADDRESS>`
3. Add these IP addresses to your `/etc/hosts` file (macOS/Linux) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
   ```text
   # Example IPs, use the ones from your nslookup command
   13.48.83.60   dagster.dev.hydrosat.task
   13.61.162.128 dagster.dev.hydrosat.task
   ```

### 2. IP Whitelisting (Security)
By default, the platform enforces strict IP whitelisting at the ingress level using AWS Security Groups. If you experience connection timeouts or "Connection Refused":
1. Check the environment configuration file: `envs/dev/dagster-values.yaml`.
2. Locate the `alb.ingress.kubernetes.io/inbound-cidrs` annotation under `ingress`.
3. Ensure your current public IP (e.g., `<YOUR_IP>/32`) is listed.
4. Apply any changes by running: `task apply -- dagster dev`.

Once configured, open your browser and navigate to: **http://dagster.dev.hydrosat.task**

## Adding a New Pipeline

Our Terraform setup uses a "Smart ConfigMap" that automatically syncs code. Here is how you deploy a new pipeline (e.g., `data_processing.py`):

### 1. Create the Code
Place your new Python file in the `stacks/k8s/dagster/pipelines/` directory.
When you run Terraform, it will automatically bundle every `.py` file in this folder into a Kubernetes ConfigMap and mount it into the Dagster pods.

### 2. Register the Deployment
To ensure complete isolation (Dagster's best practice), we spin up a separate gRPC server for each pipeline file.
1. Open `envs/dev/dagster-values.yaml`.
2. Locate the `dagster-user-deployments.deployments` list.
3. Copy the existing `dummy-pipeline` block and paste it below.
4. Update the fields for your new pipeline:
   - **name**: Change to something descriptive (e.g., `"data-processing-pipeline"`).
   - **dagsterApiGrpcArgs**: Update the path to point to your new file (e.g., `- "/opt/dagster/pipelines/data_processing.py"`).
   - **port**: Increment the port number (e.g., `3031`) to avoid TCP collisions.

### 3. Deploy
Apply the changes to update the ConfigMaps and provision the new Helm components:
```bash
task apply -- dagster dev
```

**Understanding Pod Restarts:**
- **Adding a new pipeline:** Because you added a new deployment block to `dagster-values.yaml`, Helm will automatically spin up a brand new pod. It will appear in the Dagster UI within a minute.
- **Updating existing code:** If you only modify an existing `.py` file (without changing `dagster-values.yaml`), Terraform updates the ConfigMap, but Kubernetes *does not* automatically restart the pod. To force the gRPC server to pick up your new Python code, run:
  ```bash
  kubectl rollout restart deployment dagster-user-deployments-<your-pipeline-name> -n dagster
  ```
  *(Note for future scalability: As the platform grows, we plan to deploy [stakater/reloader](https://github.com/stakater/reloader) to the cluster. This controller will natively watch for our ConfigMap updates and automatically perform safe rolling restarts of the affected Dagster pods, eliminating this manual step).*

## Accessing the API
Dagster exposes a robust GraphQL API at the same base URL as the UI.
- **GraphiQL Workspace:** Simply add `/graphql` to your Dagster URL to access an interactive IDE where you can test queries and mutations (e.g., triggering runs programmatically).
- **Programmatic Access:** You can send standard HTTP POST requests with GraphQL payloads to this endpoint. For automated workflows interacting from outside the cluster, ensure you pass the necessary ingress authentication headers.
