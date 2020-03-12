#!/bin/bash
sudo apt-get update &> /dev/null
sudo apt-get install -y awscli &> /dev/null
JOIN_USER="joindomain"
JOIN_PASS="<password>"
SUDO_FILE="/etc/sudoers"
SUDO_U="EF_SUDOERS"
SSSD_CNF="/etc/sssd/sssd.conf"

INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
if [ ! -z "$INSTANCE_ID" ] && [ ! -z "$REGION" ];then
	EC2_HOSTNAME=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags]' --instance-id  $INSTANCE_ID --region=$REGION --output=text | awk  '/Name/{print $2}')
	EC2_ENV=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags]' --instance-id  $INSTANCE_ID --region=$REGION --output=text | awk  '/ENV/{print $2}')
	EC2_TEAM=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags]' --instance-id  $INSTANCE_ID --region=$REGION --output=text | awk  '/TEAM/{print $2}')
else
	exit 
fi

IP_ADDR="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
if [ ! -z "$IP_ADDR" ];then
	! grep "$EC2_HOSTNAME" /etc/hosts &> /dev/null && echo "$IP_ADDR $EC2_HOSTNAME" >> /etc/hosts
        ! grep "$INSTANCE_ID" /etc/hosts &> /dev/null && echo "$IP_ADDR $INSTANCE_ID" >> /etc/hosts

	fi

if [ ! -z "$EC2_HOSTNAME" ];then
	hostname $EC2_HOSTNAME
	echo "$EC2_HOSTNAME" > /etc/hostname
fi

case $EC2_ENV in
	PRD)
		export DOMAIN_NAME="E1SD.COM"
		;;	
	STG|QA)
		export DOMAIN_NAME="E1EF.COM"
		;;
	*)
		echo "Please enter ENV varibales" && exit 1
esac
DOMAIN=${DOMAIN_NAME%.COM}
NAME="COM"
DOMAIN_GROUP="LINUX_${EC2_TEAM}"

#Join in domain.
sudo apt-get -y install sssd realmd krb5-user samba-common packagekit adcli &> /dev/null
echo "$JOIN_PASS" | realm join -U $JOIN_USER@$DOMAIN_NAME $DOMAIN_NAME
if [ $? -eq 0 ];then
	echo "Join domain $DOMAIN_NAME successful."
else
	echo "Join domain $DOMAIN_NAME failed."
fi
echo "$JOIN_PASS" | kinit $JOIN_USER@$DOMAIN_NAME
service sssd start

#Users in "EF_SUDOERS" group can use sudo permissions.
N_KEY=$(grep "$SUDO_U" "$SUDO_FILE")
if  [ -z "$N_KEY" ];then
	cat >>  "$SUDO_FILE" << ENDF
## Add the "AWS Delegated sudoers" group from the $DOMAIN_NAME domain.
%EF_SUDOERS@$DOMAIN_NAME ALL=(ALL:ALL) ALL
%ef_sudoers@$DOMAIN_NAME ALL=(ALL:ALL) ALL

ENDF
fi

#Specific TEAM users to login to the instance. For example,group "LINUX_ITIS"
N_KEY=$(grep "ad_access_filter" "$SSSD_CNF")
if  [ -z "$N_KEY" ];then
	cat >>  "$SSSD_CNF" << ENDF
ad_access_filter = (memberOf=cn=$DOMAIN_GROUP,ou=LINUX_GROUPS,dc=$DOMAIN,dc=$NAME)
ENDF
else
	sed -i "s/^ad_access_filter.*/ad_access_filter = (memberOf=cn=$DOMAIN_GROUP,ou=LINUX_GROUPS,dc=$DOMAIN,dc=$NAME)/gi" "$SSSD_CNF"
fi

sed -i "s#^fallback_homedir.*#fallback_homedir = /home/%d/%u#gi" "$SSSD_CNF"
service sssd restart

#Create home directory
PAM_FILE="/etc/pam.d/common-session"
N_KEY=$(grep "pam_mkhomedir.so" $PAM_FILE)
if [ -z "$N_KEY" ];then
sed  -i /pam_unix.so/a"session    required    pam_mkhomedir.so skel=/etc/skel/ umask=0022" $PAM_FILE
fi

#install SSM
if [ ! -d /tmp/ssm ];then
	mkdir -p /tmp/ssm
	wget -P /tmp/ssm https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
	sudo dpkg -i /tmp/ssm/amazon-ssm-agent.deb
fi
