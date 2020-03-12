#!/bin/sh

PRIKEY=$1
HOST=$2

cd  ~/e1-itis-asset/ansible
ansible-playbook \
	--inventory-file=./etc/hosts \
	--private-key=$PRIKEY \
	./playbooks/raw.yml \
	-e hosts=$HOST \
	-e 'raw="rm /etc/nginx/sites-enabled/default"' \
	-vvvv

