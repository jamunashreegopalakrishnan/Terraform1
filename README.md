# GitLab CI/CD for Terraform Deployment on AWS

## Overview

This project uses **GitLab CI/CD** to automate **Terraform** infrastructure deployment on **AWS**. The pipeline includes stages for:

- Validating the Terraform configuration
- Planning and applying infrastructure changes
- Testing the deployed app
- Destroying infrastructure to optimize costs

---

## Pipeline Stages

| Stage     | Description                                                         | Trigger   |
|-----------|---------------------------------------------------------------------|-----------|
| `validate`| Validates Terraform configuration syntax.                           | Automatic |
| `plan`    | Creates a Terraform execution plan and caches it.                   | Automatic |
| `apply`   | Applies the Terraform plan to provision infrastructure.             | Manual    |
| `test`    | Tests the deployed application endpoint to verify it is working.    | Manual    |
| `destroy` | Destroys all provisioned infrastructure to optimize costs.          | Manual    |

Each of these stages maps to specific Terraform commands:

| GitLab CI/CD Stage | Terraform Commands                                   |
|--------------------|------------------------------------------------------|
| `validate`         | `terraform init` + `terraform validate`              |
| `plan`             | `terraform plan -out=tfplan`                         |
| `apply`            | `terraform apply -input=false tfplan`                |
| `test`             | Bash script using `terraform output` + `curl`        |
| `destroy`          | `terraform destroy -auto-approve`                    |

---

## AWS Credentials

AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION`) are stored securely as **protected and masked CI/CD variables** in GitLab.

- These are injected at runtime and **never exposed in logs**.

---

### How to Use the Pipeline

### Validate and Plan

These stages run **automatically** on every commit or when the pipeline is triggered. 
They ensure that the Terraform code is syntactically correct and generate a plan for provisioning.

### Apply

Manually trigger this stage from the GitLab pipeline UI to **deploy infrastructure** using the saved execution plan.

### Test

Manually trigger this after applying. It runs a test script to confirm the deployed application is reachable.

#### Example Test Stage Script

```bash
export ALB_DNS_NAME=$(terraform output -raw alb_dns_name)
echo "Testing app at http://$ALB_DNS_NAME ..."
curl -f http://$ALB_DNS_NAME/ || (echo "App test failed!" && exit 1)
```

### Destroy

Once the testing is complete, trigger the `destroy` stage to tear down all provisioned resources. This **avoids incurring unnecessary AWS costs**.

---

## Cost Optimization

The `destroy` stage is **critical for cost management**. It ensures infrastructure is not left running and charging my account after usage. 

---

## Troubleshooting

| Issue                        | Solution                                                                 |
|------------------------------|--------------------------------------------------------------------------|
| Terraform init fails         | Ensure `.terraform.lock.hcl` is committed and caching is enabled.        |
| Test stage fails             | Check if ALB DNS is correct and app is running.                          |
| Permission denied errors     | Ensure IAM user has the correct AWS policies and permissions.            |
| No config files error        | Ensure `.tf` files exist in the working directory during pipeline run.   |

---
## Testing Locally
   ```bash
   # Move into the terraform directory
   cd terraform

   # Initialize the working directory
   terraform init

   # (Optional) Format and validate the code
   terraform fmt -check
   terraform validate

   # See what changes will be made
   terraform plan

   # Apply the changes (creates/updates resources)
   terraform apply

   # View outputs (such as ALB DNS name)
   terraform output
   
   After deploying infrastructure, Terraform will display the ALB DNS name in the output. You can use that DNS name to test the application from your local machine
   # Test the deployment
   curl http://<the-alb-dns-name>/
   If the app is working, it should return a valid HTTP response. If not, you may see an error or timeout — which indicates a misconfigured or offline app

   # Destroy all resources when done
   terraform destroy
```

### Prerequisites

1. **Terraform Installed**

   Install Terraform (`>= 1.3.0`)  
     [Download Terraform](https://www.terraform.io/downloads.html)

2. **Export AWS Credentials**

   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key-id"
   export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
   export AWS_REGION="your-region"  # e.g., ap-south-1
   ```

3. **Access to Terraform Code**

   Ensure you have access to the `.tf` files and `terraform.tfstate`.

---

## Summary

- Infrastructure is deployed using GitLab pipelines and Terraform.
- You can destroy resources both from GitLab or locally.
- AWS credentials are securely managed using CI/CD variables.
- Clean up using the `destroy` stage or local `terraform destroy`.

---
