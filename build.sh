#!/bin/bash

VM_USERNAME=""
VM_PASSWORD=""
VM_TYPE=""
AWS_ACESSS_KEY=""
AWS_SECRET_KEY=""

function run_packer_vmware {
  packer build --only=vmware-iso -var "username=$VM_USERNAME" -var "password=$VM_PASSWORD" template.json
}

function run_packer_vbox {
  packer build --only=virtualbox-iso -var "username=$VM_USERNAME" -var "password=$VM_PASSWORD" template.json
}

function run_packer_aws {
	 packer build --only=amazon-ebs -var "username=$VM_USERNAME" -var "password=$VM_PASSWORD" template.json
}

function generate_pressed {
  sed "s/newusername/$VM_USERNAME/g;s/newpassword/$VM_PASSWORD/g" ubuntu/http/preseed.cfg.template > ubuntu/http/preseed.cfg
}

function help {
  echo "Usage:"
  echo "  build.sh -t"
  echo ""
  echo "Arguments:"
  echo "  -t <vmware|vbox|aws>\t VM Type of virtual machine. "
  echo ""
  echo "optionals:"
  echo "  -u <username>\t\t Username of virtual machine."
  echo "  -p <password>\t\t Password of Virtual machine. Not recommended leaks creds."
  echo "  -a <aws_access_key>\t\t AWS Accesss Key."
	echo "  -s <aws_secret_key>\t\t AWS Secret Key."
}

# Main Application
[[ ! $2 ]] && { help; exit 0; }

#Note that 'b' switch is broken
while getopts "t:u:p:a:s:h" OPT; do
  case $OPT in
  h) help; exit 1;;
  t) VM_TYPE="$OPTARG";;
  u) VM_USERNAME="$OPTARG";;
  p) VM_PASSWORD="$OPTARG";;
	a) AWS_ACESSS_KEY="$OPTARG";;
	s) AWS_SECRET_KEY="$OPTARG";;
  *) echo "Unknown Command"; exit 1;;
  esac
done

if [ -z $VM_TYPE ]; then
  echo "[!] - ERROR: Missing VM Type."
  exit 1;
fi

if [[ "${VM_USERNAME}" = "" && "${VM_TYPE}" != "aws" ]]; then
  read -p  "Enter username: " VM_USERNAME
fi

if [[ "${VM_PASSWORD}" = "" && "${VM_TYPE}" != "aws" ]]; then
  read -s -p "Enter Password: " VM_PASSWORD
fi

generate_pressed
cd ubuntu

case "$VM_TYPE" in
  vmware)
    run_packer_vmware
  ;;
  vbox)
    run_packer_vbox
  ;;
  aws)
		export AWS_ACCESS_KEY_ID=$AWS_ACESSS_KEY
	  export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
		env 
		run_packer_aws
  ;;
  *)
    echo "[!] - ERROR: You are querying an un-supported platform!"
    exit 1
  ;;
esac

echo "Deleting temporary preseed.cfg file"
rm `pwd`/http/preseed.cfg
