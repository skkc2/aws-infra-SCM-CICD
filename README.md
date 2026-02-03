
# aws-infra-SCM-CICD

Purpose:
- Terraform-based infrastructure to host GitHub Enterprise Server (GHE) and Jenkins on EC2 in AWS.
- Private, multi-AZ design with restricted public access via ALB + WAF IP allowlist.
- Secrets in AWS Secrets Manager, KMS encryption, CloudWatch/SNS/SES alerts, automated backups (EBS snapshots every 6 hours).
- Target region: eu-west-1.

Important prerequisites:
1. Create S3 backend bucket `aws-terraform-backend` and DynamoDB table `terraform-locks` for state locking (or update terraform/backend.tf).
2. Create S3 bucket `ghe-license` and upload your GHE license file (key variable).
3. Ensure AWS credentials with permissions to create resources are configured for Terraform.
4. Verify SES identity if you plan to use SES for alerts.
5. Replace placeholder domain names (ghe.replace-me.example.com, jenkins.replace-me.example.com) and ACM cert ARNs.

Quick start (prod):
- cd terraform/environments/prod
- terraform init
- terraform plan -var-file=terraform.tfvars
- terraform apply -var-file=terraform.tfvars

Notes:
- This is a scaffold. Review security settings, AMI choices, instance types, and adjust sizes before deploying to production.
- Use SSM Session Manager for host access (no SSH open to internet).
- Jenkins agents use ASG with spot instance support — configure spot fallbacks as needed.

Modules overview:
- vpc: VPC and subnets across 3 AZs
- security: Security Groups & IAM roles
- alb: ALBs for GHE and Jenkins
- ec2: base EC2 launch templates / roles
- ghe: GHE EC2 instance(s), license provisioning
- jenkins: Jenkins master (persistent) & EFS; agents via autoscaling
- autoscaling: agent ASG/launch template
- waf: WAF IP allowlist
- monitoring: CloudWatch logs/alarms, SNS, SES integration
- backups: AWS Data Lifecycle Manager for recurring EBS snapshots

Replaceable placeholders:
- domain_name, hosted_zone_id, allowed_ipv4_cidrs, allowed_ipv6_cidrs, ghe_license_s3_bucket/key, backend S3 bucket, ACM cert ARNs, kms_key_alias

Support:
- This repo is a starting point; do a security review, run in staging, and validate backups and restore procedures.
