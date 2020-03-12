#!/bin/bash

#author: bob.yeh@ef.com
#Steps
#1. pull the athena configuration from git
#2. copy the config file from git repo dir to template dir
#3. deploy the config template(j2) to machine
#4. restart the nginx servic

PRIKEY=$1
ENV=$2
LIST=MPLS-Squid-AutoSwitch-squid-$ENV.list
S_HOST=$3

#cd ~/e1-itis-asset
cd ../../
PWD=`pwd`
#1
git pull origin master

#2
cp -r MPLS-Squid-AutoSwitch/squid ansible/templates
cd ansible/templates/squid/$ENV
find . -type f | grep -v j2 | sed -e 's/^.\///g' > ../$LIST

cd ..
PWD=`pwd`
TEMPLATES=`cat $LIST`
cd ..
for i in $TEMPLATES;
do 
    SRC=$PWD/squid/$ENV/$i".j2"
    DEST="/usr/local/squid/etc/"$i
    cp $PWD/squid/$ENV/$i $SRC   

    ansible-playbook --inventory-file=../etc/hosts \
                     --private-key=$PRIKEY \
		     ../playbooks/deploy-template.yml \
		     -e hosts=$S_HOST \
                     -e src=$SRC \
                     -e dest=$DEST \
                     -v
done;

#ansible-playbook --inventory-file=../etc/hosts \
#                 --private-key=$PRIKEY \
#                 ../playbooks/raw.yml \
#                 -e hosts=$S_HOST \
#                 -e 'raw="/usr/local/squid/sbin/squid -k kill"' \
#                 -vvvv

#ansible-playbook --inventory-file=../etc/hosts \
#                 --private-key=$PRIKEY \
#                 ../playbooks/raw.yml \
#                 -e hosts=$S_HOST \
#                 -e 'raw="pgrep squid | xargs kill -9 "' \
#                 -vvvv


if [ "$ENV" == "cn" ];
then
    ansible-playbook --inventory-file=../etc/hosts \
                 --private-key=$PRIKEY \
                 ../playbooks/shell.yml \
                 -e hosts=$S_HOST \
                 -e 'shell="killall -9  /usr/local/squid/sbin/squid  && sudo /usr/local/squid/sbin/squid -f /usr/local/squid/etc/squid4-mpls.conf"' \
                 -vvvv
fi

if [ "$ENV" == "sg" ];
then
    ansible-playbook --inventory-file=../etc/hosts \
                 --private-key=$PRIKEY \
                 ../playbooks/shell.yml \
                 -e hosts=$S_HOST \
                 -e 'shell=" sudo killall -9  /usr/local/squid/sbin/squid && sudo /usr/local/squid/sbin/squid -f /usr/local/squid/etc/squid4.conf"' \
                 -vvvv

fi

