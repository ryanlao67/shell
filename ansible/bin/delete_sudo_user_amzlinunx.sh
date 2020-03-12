#!/bin/bash
ansible-playbook \
	--inventory-file=../etc/hosts /home/ubuntu/e1-itis-asset/ansible/playbooks/delete_sudo_user_amzlinux.yml \
	-u ubuntu \
	--private-key=$1 \
	-e rmuser=ec2-user \
	-e servers_var=$2 \
	-e users=$3
