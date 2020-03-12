#!/bin/sh

PRIKEY=$1
HOST=$2
SERVICE=$3
STAT=$4

    ansible-playbook --inventory-file=../etc/hosts \
                     --private-key=$PRIKEY \
                     ../playbooks/control-service.yml \
                     -e hosts=$HOST \
                     -e stat=$STAT \
                     -e service=$SERVICE \
		     -v

