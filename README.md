# Class-IaC-auto-Deploy

This project showcases automated Infrastructure as Code (IaC) deployment using Terraform with a CI/CD pipeline via GitHub Actions. The infrastructure provisions a VPC with EC2 instances (1 master and 5 workers) in AWS.

## Project Overview

This Terraform project deploys:
- **VPC** with public subnet in `us-east-2`
- **Internet Gateway** and **Route Table** for public internet access
- **Security Group** allowing SSH (22), HTTP (80), and HTTPS (443)
- **IAM Role** and **Instance Profile** for EC2 instances with EC2 full access
- **1 Master EC2 Instance** (t3.micro)
- **5 Worker EC2 Instances** (t3.micro)

## Prerequisites

Before running this project, ensure you have:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** >= 1.6.0 installed
4. **GitHub Account** with repository access
5. **EC2 Key Pair** named `1PU_key` in the `us-east-2` region (or update `variables.tf`)

## ⚠️ Critical: S3 Backend Setup (REQUIRED)

**Before running any Terraform commands or triggering the CI/CD pipeline, you MUST create the S3 bucket for Terraform state storage.**

### Step 1: Create the S3 Bucket

The Terraform backend requires an S3 bucket named `automation-2025-tfstate` in the `us-east-2` region. This bucket must be created **manually** before any automation runs.

#### Using AWS CLI:

```bash
aws s3api create-bucket \
  --bucket automation-2025-tfstate \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2
```

#### Using AWS Console:

1. Navigate to S3 in the AWS Console
2. Click "Create bucket"
3. Bucket name: `automation-2025-tfstate`
4. AWS Region: `us-east-2` (Ohio)
5. **Uncheck** "Block all public access" (or configure as needed)
6. Click "Create bucket"

### Step 2: Enable Versioning

Versioning must be enabled on the bucket to track state file changes:

```bash
aws s3api put-bucket-versioning \
  --bucket automation-2025-tfstate \
  --versioning-configuration Status=Enabled
```

Or via AWS Console:
1. Select the `automation-2025-tfstate` bucket
2. Go to the "Properties" tab
3. Scroll to "Bucket Versioning"
4. Click "Edit" → Select "Enable" → Save

### Step 3: Enable Object Locking

Object locking prevents accidental deletion of state files:

```bash
aws s3api put-object-lock-configuration \
  --bucket automation-2025-tfstate \
  --object-lock-configuration '{
    "ObjectLockEnabled": "Enabled",
    "Rule": {
      "DefaultRetention": {
        "Mode": "COMPLIANCE",
        "Days": 30
      }
    }
  }'
```

**Note:** Object locking can only be enabled when creating a new bucket. If you've already created the bucket, you'll need to:
1. Delete the bucket (if empty)
2. Recreate it with object locking enabled

Or via AWS Console:
1. When creating the bucket, under "Advanced settings"
2. Enable "Object Lock"
3. Configure retention mode (Compliance recommended)
4. Set retention period (e.g., 30 days)

### Verification

Verify the bucket configuration:

```bash
# Check bucket exists
aws s3 ls s3://automation-2025-tfstate

# Check versioning
aws s3api get-bucket-versioning --bucket automation-2025-tfstate

# Check object locking
aws s3api get-object-lock-configuration --bucket automation-2025-tfstate
```

## Local Setup and Execution

### 1. Clone the Repository

```bash
git clone https://github.com/1PU2021/Class-IaC-auto-Deploy.git
cd Class-IaC-auto-Deploy
```

### 2. Navigate to Terraform Directory

```bash
cd terraform
```

### 3. Initialize Terraform

This will configure the S3 backend (the bucket must exist first):

```bash
terraform init
```

### 4. Review the Execution Plan

```bash
terraform plan
```

### 5. Apply the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 6. View Outputs

After deployment, view the created resources:

```bash
terraform output
```

This will show:
- VPC ID
- Master EC2 Public IP
- Master EC2 Public DNS

### 7. Destroy Infrastructure (Optional)

To tear down all resources:

```bash
terraform destroy
```

## CI/CD Pipeline Setup (GitHub Actions)

The project includes a GitHub Actions workflow that automatically runs Terraform on pushes to the `main` branch.

### Required GitHub Secrets

Configure the following secrets in your GitHub repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following secrets:

- `AWS_ACCESS_KEY_ID`: Your AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key

### Pipeline Workflow

The pipeline (`.github/workflows/terraform-deploy.yml`) performs:

1. **Checkout** repository code
2. **Configure AWS credentials** using GitHub secrets
3. **Setup Terraform** (version 1.9.0)
4. **Initialize** Terraform (`terraform init`)
5. **Validate** Terraform configuration (`terraform validate`)
6. **Plan** changes (`terraform plan`)
7. **Apply** changes automatically on `main` branch (`terraform apply`)

### Triggering the Pipeline

The pipeline runs automatically on:
- **Push** to `main` branch
- **Pull requests** (plan only, no apply)

## Configuration Variables

Default values can be overridden in `terraform/variables.tf` or via command line:

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-2` | AWS region for deployment |
| `project_name` | `iac-demo` | Prefix for resource names |
| `ec2_ami` | `ami-0c5ddb3560e768732` | Ubuntu 22.04 LTS AMI (us-east-2) |
| `ec2_type` | `t3.micro` | EC2 instance type |
| `key_name` | `1PU_key` | EC2 key pair name |

### Override Variables

```bash
terraform apply -var="project_name=my-project" -var="ec2_type=t3.small"
```

## Project Structure

```
Class-IaC-auto-Deploy/
├── .github/
│   └── workflows/
│       └── terraform-deploy.yml    # CI/CD pipeline
├── terraform/
│   ├── backend.tf                  # S3 backend configuration
│   ├── provider.tf                 # AWS provider setup
│   ├── variables.tf                # Input variables
│   ├── vpc.tf                      # VPC, subnet, IGW, routes
│   ├── security.tf                 # Security groups
│   ├── iam.tf                      # IAM roles and policies
│   ├── master-ec2.tf               # Master EC2 instance
│   ├── worker-ec2.tf               # Worker EC2 instances
│   └── outputs.tf                  # Output values
├── LICENSE
└── README.md
```

## Troubleshooting

### Error: S3 bucket does not exist

```
Error: Failed to get existing workspaces: S3 bucket "automation-2025-tfstate" does not exist.
```

**Solution:** Create the S3 bucket with versioning and object locking enabled as described in the [S3 Backend Setup](#-critical-s3-backend-setup-required) section above.

### Error: Access Denied

If you encounter permission errors, ensure:
- AWS credentials have sufficient permissions (EC2, VPC, IAM, S3)
- GitHub secrets are correctly configured
- The S3 bucket policy allows your AWS account to read/write

### Error: Key Pair Not Found

```
Error: InvalidKeyPair.NotFound
```

**Solution:** Create an EC2 key pair named `1PU_key` in the `us-east-2` region, or update the `key_name` variable in `terraform/variables.tf`.

## Security Considerations

- The security group allows SSH from `0.0.0.0/0`. Consider restricting this to your IP address in production.
- EC2 instances have full EC2 access via IAM role. Limit permissions based on your requirements.
- Ensure AWS credentials are stored securely and never committed to the repository.

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Support

For issues or questions, please open an issue in the GitHub repository.
