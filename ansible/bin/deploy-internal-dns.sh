#!/bin/sh

#Steps
#1. pull the internal dns configuration from git
#2. copy the config file from git repo dir to template dir
#3. deploy the config template(j2) to machine
#4. restart the bind9 service

PRIKEY=$1
ENV=$2
# ENV = hostname|cne1prditisdns-01|sge1prditisdns-01
ZONE_FILE=internal-dns-records

cd ../..
#1
git pull origin master

#2 Deploy DNS configration file.
cp -r Infra-Server-DNS-Configs/$ENV  ansible/templates
cd ansible/templates/$ENV
find . -type f | grep -v j2 | sed -e 's/^.\///g' > ../$ENV-configfile.list

cd ..
PWD=`pwd`
TEMPLATES=`cat $ENV-configfile.list`
for i in $TEMPLATES;
do 
    SRC=$PWD/$ENV/$i".j2"
    DEST="/etc/bind/"$i
    cp $ENV/$i $SRC   
    ansible-playbook --inventory-file=../etc/hosts \
                     --private-key=$PRIKEY \
		     ../playbooks/deploy-template.yml \
		     -e hosts=$ENV \
                     -e src=$SRC \
                     -e dest=$DEST \
                     -v
done;

#3 Deploy DNS record config.
cd ../..
PWD=`pwd`
#echo \$PWD=$PWD

#exit
cp -r Infra-Server-DNS-Configs/$ZONE_FILE  ansible/templates
cd ansible/templates/$ZONE_FILE
find . -type f | grep -v j2 | sed -e 's/^.\///g' > ../$ZONE_FILE-configfile.list

cd ..
PWD=`pwd`
TEMPLATES=`cat $ZONE_FILE-configfile.list`
for i in $TEMPLATES;
do 
    SRC=$PWD/$ZONE_FILE/$i".j2"
    DEST="/etc/bind/zones/"$i
    cp $ZONE_FILE/$i $SRC   
    ansible-playbook --inventory-file=../etc/hosts \
                     --private-key=$PRIKEY \
		     ../playbooks/deploy-template.yml \
		     -e hosts=$ENV \
                     -e src=$SRC \
                     -e dest=$DEST \
                     -v
done;

#4 Restart DNS service.
ansible-playbook --inventory-file=../etc/hosts \
                     --private-key=$PRIKEY \
                     ../playbooks/control-service.yml \
                     -e hosts=$ENV \
                     -e stat=restarted \
                     -e service=bind9 \
		     -v

