aws configure setup credentials for aws 

cd /home/debarshi/Prototype/cloudbuilderprototype/terraform/stage2-networking-services

terraform init -backend-config="bucket=cloudbuilderprototype-tfstate-prod" -backend-config="key=stage2-networking-services/terraform.tfstate" -backend-config="region=us-east-1"

terraform plan
