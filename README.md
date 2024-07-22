# pep-restaurant-infra
Pep Restaurant Infrastructure 

# Before run Infrastructure
Delete Secrets
aws secretsmanager delete-secret --secret-id SECRET_ID --force-delete-without-recovery

Change name of resources:
db.tf
eks.tf
secrets.tf

Deploy pipeline Run Terraform action 2 (to not save state on S3)

# Infrastructure Phase 1 
IAM
CLOUDWATCH
ECR
VPC
S3

# Infrastructure Phase 2
RDS
RDS - SUBNET GROUPS
EKS
KMS
CLOUDWATCH
SECRET
