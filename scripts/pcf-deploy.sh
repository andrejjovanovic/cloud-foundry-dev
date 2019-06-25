#!/bin/bash
echo "Welcome to the cf-lite deployment based on bosh-lite v2 and cfv2."
echo ""
echo ""
echo " ██████╗███████╗    ██╗     ██╗████████╗███████╗"
echo "██╔════╝██╔════╝    ██║     ██║╚══██╔══╝██╔════╝"
echo "██║     █████╗█████╗██║     ██║   ██║   █████╗  "
echo "██║     ██╔══╝╚════╝██║     ██║   ██║   ██╔══╝  "
echo "╚██████╗██║         ███████╗██║   ██║   ███████╗"
echo " ╚═════╝╚═╝         ╚══════╝╚═╝   ╚═╝   ╚══════╝"

cd $CF_WORKSPACE/workspace

# wget -q https://github.com/cloudfoundry/bosh-cli/releases/download/v5.5.1/bosh-cli-5.5.1-linux-amd64
# mv bosh-cli-5.5.1-linux-amd64 bosh
# chmod +x ./bosh
# sudo mv ./bosh /usr/bin/bosh
# rm bosh-cli-5.5.1-linux-amd64
# echo "Bosh cli deployed | `bosh -v`"

# echo "#### Cloud Foundry CLI #####"
# wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
# echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
# sudo apt-get update
# sudo apt-get install cf-cli

echo "#### BOSH deploy ######"
# Clone the bosh-deployment repo in seperate folder
git clone https://github.com/cloudfoundry/bosh-deployment
cd $CF_WORKSPACE/workspace/bosh-deployment
# Deploy bosh environment to Virtual Machine

bosh create-env bosh.yml --state=state.json -o gcp/cpi.yml -o gcp/bosh-lite-vm-type.yml -o external-ip-not-recommended.yml -o bosh-lite.yml -o bosh-lite-runc.yml --vars-store creds.yml -v director_name=bosh-lite -v internal_cidr=$CIDR_RANGE -v internal_gw=$SUBNET_GATEWAY -v internal_ip=$INTERNAL_IP --var-file gcp_credentials_json=$TF_VAR_credentials_path -v project_id=$TF_VAR_project_id -v external_ip=$GLOBAL_IP -v zone=$COMPUTE_REGION_ID -v tags=[bosh-lite] -v network=$NETWORK_NAME -v subnetwork=$SUBNET_NAME
# Set enviroment variables
export BOSH_ENVIRONMENT=$GLOBAL_IP
export BOSH_CA_CERT="$(bosh int creds.yml --path /director_ssl/ca)"
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int creds.yml --path /admin_password`
export SYSTEM_DOMAIN=$BOSH_ENVIRONMENT.sslip.io
bosh alias-env bosh-lite -e $BOSH_ENVIRONMENT --ca-cert "$(bosh int creds.yml --path /director_ssl/ca)"

echo "#### Deploy CloudFoundry ####"
# Clone the cf-deployment repository
cd $CF_WORKSPACE/workspace
git clone https://github.com/cloudfoundry/cf-deployment
#cd ~/workspace/cf-deployment
cd $CF_WORKSPACE/workspace/bosh-deployment
# Replace the stemcell version with latest one in cf-deployment file
sed -i 's/315.36/315.41/g' $CF_WORKSPACE/workspace/cf-deployment/cf-deployment.yml
# Upload cloud config to bosh director
bosh update-cloud-config $CF_WORKSPACE/workspace/cf-deployment/iaas-support/bosh-lite/cloud-config.yml
# Upload stemcells to virtual machine
bosh upload-stemcell "https://s3.amazonaws.com/bosh-core-stemcells/315.41/bosh-stemcell-315.41-warden-boshlite-ubuntu-xenial-go_agent.tgz"
# Add the configuration for DNS resolving
bosh update-runtime-config "$(bosh int runtime-configs/dns.yml --vars-store deployment-vars.yml)" --name dns
# Deploy cloud foundry using the bosh
bosh -d cf deploy $CF_WORKSPACE/workspace/cf-deployment/cf-deployment.yml -o $CF_WORKSPACE/workspace/cf-deployment/operations/bosh-lite.yml -o $CF_WORKSPACE/workspace/cf-deployment/operations/use-compiled-releases.yml --vars-store deployment-vars.yml -v system_domain=$SYSTEM_DOMAIN
# Printing out the credentials
echo "#### CF login credentials ###"
echo "username/email: admin"
bosh interpolate --path /cf_admin_password $CF_WORKSPACE/workspace/bosh-deployment/deployment-vars.yml