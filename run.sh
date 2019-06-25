#!/bin/bash
export CF_WORKSPACE="$(pwd)"
cd $CF_WORKSPACE/terraform
export global_ip="$(terraform output | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")"
echo $global_ip