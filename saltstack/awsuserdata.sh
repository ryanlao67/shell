#!/bin/bash
#apt-get update
apt-get install -y awscli

INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
if [ ! -z "$INSTANCE_ID" ] && [ ! -z "$REGION" ];then
	EC2_HOSTNAME=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags]' --instance-id  $INSTANCE_ID --region=$REGION --output=text | awk  '/Name/{print $2}')
else
	exit 
fi

IP_ADDR="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
if [ ! -z "$IP_ADDR" ];then
	! grep "$IP_ADDR" /etc/hosts &> /dev/null && echo "$IP_ADDR $EC2_HOSTNAME" >> /etc/hosts
	fi

if [ ! -z "$EC2_HOSTNAME" ];then
	hostname $EC2_HOSTNAME
	echo "$EC2_HOSTNAME" > /etc/hostname
fi

wget -O - https://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
SOURCE_LIST="deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest trusty main"
! grep "$SOURCE_LIST" /etc/apt/sources.list &>/dev/null && echo "$SOURCE_LIST" >> /etc/apt/sources.list
apt-get update

dpkg -l  salt-minon &> /dev/null ||  apt-get install -y salt-minion

NAME_KEY="$(grep "CNE1PRDITIS-CORE" /etc/salt/minion)"
if [ -z "$NAME_KEY" ];then
	echo "master: CNE1PRDITIS-CORE" >> /etc/salt/minion
fi
NAME_KEY2="$(grep "$EC2_HOSTNAME" /etc/salt/minion)"
if [ -z "$NAME_KEY2" ];then
	echo "id: $EC2_HOSTNAME" >> /etc/salt/minion
fi


/etc/init.d/salt-minion  restart
salt-call state.highstate
