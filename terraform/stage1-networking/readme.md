aws configure setup credentials for aws 

cd /home/debarshi/Prototype/cloudbuilderprototype/terraform/stage1-networking

terraform init -backend-config="bucket=cloudbuilderprototype-tfstate-prod" -backend-config="key=stage1-networking/terraform.tfstate" -backend-config="region=us-east-1"

terraform plan