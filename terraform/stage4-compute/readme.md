aws configure setup credentials for aws 

cd /home/debarshi/Prototype/cloudbuilderprototype/terraform/stage4-compute

terraform init -backend-config="bucket=cloudbuilderprototype-tfstate-prod" -backend-config="key=stage4-compute/terraform.tfstate" -backend-config="region=us-east-1"

terraform plan
