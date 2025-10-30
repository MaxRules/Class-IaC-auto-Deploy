name: Terraform CI/CD Pipeline

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  terraform:
    name: Terraform Plan and Apply
    runs-on: ubuntu-latest

    permissions:
      contents: read
      id-token: write

    # 👇 This ensures all Terraform commands run inside the terraform/ folder
    defaults:
      run:
        working-directory: terraform

    steps:
      # 1️⃣ Checkout the repository
      - name: Checkout repository
        uses: actions/checkout@v4

      # 2️⃣ Configure AWS credentials
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-2

      # 3️⃣ Setup Terraform
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0

      # 4️⃣ Initialize Terraform
      - name: Terraform Init
        run: terraform init -input=false

      # 5️⃣ Validate Terraform configuration
      - name: Terraform Validate
        run: terraform validate

      # 6️⃣ Plan Terraform changes
      - name: Terraform Plan
        run: terraform plan -out=tfplan

      # 7️⃣ Apply Terraform (only on main branch)
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
