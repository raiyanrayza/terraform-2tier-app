# terraform-2tier

# AWS Infrastructure with Terraform

This repository contains Terraform scripts to create a basic AWS infrastructure with the following resources:

- Custom VPC
- 2 Public Subnets (CIDR: 10.0.1.0/24, 10.0.2.0/24) Note:  Architecture diagram has 10.2.1.0/24 cidr block which is not suitable
- 2 Private Subnets (CIDR: 10.0.3.0/24, 10.0.4.0/24)
- Internet Gateway
- 2 EC2 Instances
- Application Load Balancer (ALB)
- RDS Instance

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/your-repo.git
   ```

2. Navigate to the project directory:

   ```bash
   cd terraform
   ```

3. Edit `terraform.tfvars` with your desired variable values.

4. Initialize Terraform:

   ```bash
   terraform init
   ```

5. Plan and apply the infrastructure:

   ```bash
   terraform apply -var-file=terraform.tfvars
   ```

   Confirm with `yes` when prompted.

6. After completion, verify resources:

   ```bash
   terraform output alb_dns_name
   terraform output rds_endpoint
   ```

7. When done, destroy the resources:

   ```bash
   terraform destroy -var-file=terraform.tfvars
   ```

## Outputs

- **ALB DNS Name:**

   ```bash
   terraform output alb_dns_name
   ```

- **RDS Endpoint:**

   ```bash
   terraform output rds_endpoint
   ```

Feel free to customize the configurations according to your requirements.
