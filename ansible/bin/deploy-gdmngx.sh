#!/bin/sh

#Steps
#1. pull the athena configuration from git
#2. copy the config file from git repo dir to template dir
#3. deploy the config template(j2) to machine
#4. restart the nginx servic

# TODO: to put if [ $# -ne 2 ]; print usage help

PRIKEY=$1
ENV=$2

# ENV = sge1prdgdmngx|cne1prdgdmngx

#cd ~/e1-itis-asset
#1
#git pull origin master

cd ../..
#1
git pull origin master


#2
cp -r Infra-Server-Nginx-Configs/$ENV ansible/templates
cd ansible/templates/$ENV
find . -type f | grep -v j2 | sed -e 's/^.\///g' > ../$ENV.list
cd ..
TEMPLATES=`cat $ENV.list`
PWD=`pwd`
for i in $TEMPLATES;
do 
    SRC=$PWD/$ENV/$i".j2"
    DEST="/etc/nginx/"$i
    cp $ENV/$i $SRC   

    ansible-playbook --inventory-file=../etc/hosts \
                     --private-key=$PRIKEY \
		             ../playbooks/deploy-template.yml \
		             -e hosts=$ENV \
                     -e src=$SRC \
                     -e dest=$DEST \
                     -v
done;


ansible-playbook --inventory-file=../etc/hosts \
                     --private-key=$PRIKEY \
                     ../playbooks/raw.yml \
                     -e hosts=$ENV \
                     -e 'raw="sudo service nginx configtest"' \

if [ $? -ne 0 ];then
 echo "Nginx Configure file SyntaxError" && exit 1

else
    ansible-playbook --inventory-file=../etc/hosts \
                     --private-key=$PRIKEY \
                     ../playbooks/control-service.yml \
                     -e hosts=$ENV \
                     -e stat=restarted \
                     -e service=nginx \
		             -v

fi
