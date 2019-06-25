#!/bin/bash
# Setting env variables
export CF_WORKSPACE="$(pwd)"
export TF_VAR_credentials_path="~/account.json"
export TF_VAR_project_id="ace-tranquility-243609"
export TF_VAR_region_id="us-east1"

# Runing Terraform infrastructure scripts
cd $CF_WORKSPACE/terraform
terraform apply
export GLOBAL_IP="$(terraform output global_ip)"
export CIDR_RANGE="$(echo var.cidr_range | terraform console)"
export NETWORK_NAME="$(echo var.network_name | terraform console)"
export SUBNET_NAME="$(echo var.subnet_name | terraform console)"
export SUBNET_GATEWAY="$(terraform output subnet_gateway)"
export INTERNAL_IP="$(echo $SUBNET_GATEWAY | sed 's:[^.]*$:2:')"
export COMPUTE_REGION_ID="$TF_VAR_region_id-c"

# Runnign pcf deploy
sh $CF_WORKSPACE/scripts/pcf-deploy.sh
