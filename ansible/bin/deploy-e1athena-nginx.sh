#!/bin/sh

#Steps
#1. pull the athena configuration from git
#2. copy the config file from git repo dir to template dir
#3. deploy the config template(j2) to machine
#4. restart the nginx servic

PRIKEY=$1
ENV=$2
# ENV = live|staging

cd ../..
#1
git pull origin master

#2
cp -r Infra-Server-Nginx-Configs/e1athena-$ENV-nginx ansible/templates
cd ansible/templates/e1athena-$ENV-nginx
find . -type f | grep -v j2 | sed -e 's/^.\///g' > ../e1athena-$ENV-nginx.list

cd ..
PWD=`pwd`
TEMPLATES=`cat e1athena-$ENV-nginx.list`
for i in $TEMPLATES;
do 
    SRC=$PWD/e1athena-$ENV-nginx/$i".j2"
    DEST="/etc/nginx/"$i
    cp e1athena-$ENV-nginx/$i $SRC   

    ansible-playbook --inventory-file=../etc/hosts \
                     --private-key=$PRIKEY \
		     ../playbooks/deploy-template.yml \
		     -e hosts=e1athena-$ENV \
                     -e src=$SRC \
                     -e dest=$DEST \
                     -v
done;

    ansible-playbook --inventory-file=../etc/hosts \
                     --private-key=$PRIKEY \
                     ../playbooks/control-service.yml \
                     -e hosts=e1athena-$ENV \
                     -e stat=restarted \
                     -e service=nginx \
		     -v

