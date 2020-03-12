#!/bin/bash

hostfile=''
keyfile=''

ECHO_USAGE(){
cat   << EOF
Usage:
	bash $(basename $0 )   KEY_FILE  HOST_TAG USER_NAME

EOF
}
[ $# -eq 0 ] && ECHO_USAGE && exit 1

# ansible-playbook create sudo user
ansible-playbook \
	--inventory-file=../etc/hosts /home/ubuntu/e1-itis-asset/ansible/playbooks/sudo_amzlinux.yml \
	-u ubuntu \
	--private-key=$1 \
	-e rmuser=ec2-user \
	-e servers_var=$2 \
	-e users=$3