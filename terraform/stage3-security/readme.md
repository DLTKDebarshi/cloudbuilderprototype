aws configure setup credentials for aws 

cd /home/debarshi/Prototype/cloudbuilderprototype/terraform/stage3-security

terraform init -backend-config="bucket=cloudbuilderprototype-tfstate-prod" -backend-config="key=stage3-security/terraform.tfstate" -backend-config="region=us-east-1"

terraform plan
