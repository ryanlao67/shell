#!/bin/bash

INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
[ ! -z "$INSTANCE_ID" && ! -z "$REGION" ] && EC2_HOSTNAME=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags]' --instance-id  $INSTANCE_ID --region=$REGION --output=text | awk  '/Name/{print $2}')
IP_ADDR="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
if [ ! -z "$IP_ADDR" ];then
	if [ ! grep "$IP_ADDR" &> /dev/null ];then
		echo "$IP_ADDR $EC2_HOSTNAME" >> /etc/hosts
	fi
fi

sudo yum install https://repo.saltstack.com/yum/amazon/salt-amzn-repo-latest-2.amzn1.noarch.rpm
sudo yum install salt-minion

if [ ! grep "CNE1PRDITIS-CORE" /etc/salt/minion &> /dev/null ];then
	echo "master: CNE1PRDITIS-CORE" >> /etc/salt/minion
fi

sudo service salt-minion restart 

#su hadoop
#hdfs dfs -mkdir /user/biuser
#hdfs dfs -chown -R biuser:biuser /user/biuser
