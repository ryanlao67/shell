#!/bin/sh
PRIKEY=$1
HOST=$2
SERVICE=$3

cd  ~/e1-itis-asset/ansible
ansible-playbook --inventory-file=./etc/hosts \
                     --private-key=$PRIKEY \
                     ./playbooks/deploy-service.yml \
                     -e hosts=$HOST \
                     -e service=$SERVICE \
                     -v

