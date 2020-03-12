#Steps
PRIKEY=$1
HOST=$2
TARGET_PATH="EC2-Linux-Collectd"
cd ~/e1-itis-asset
#1
git pull origin master

#2
cp -r $TARGET_PATH ansible/templates
cd  ~/e1-itis-asset/ansible/templates/$TARGET_PATH
find . -type f | grep -v j2 | sed -e 's/^.\///g' > ../EC2-Linux-Collectd.list
TEMPLATES=`cat ../EC2-Linux-Collectd.list`

cd  ~/e1-itis-asset/ansible
ansible-playbook --inventory-file=./etc/hosts \
                     --private-key=$PRIKEY \
                     ./playbooks/mkdir.yml \
                     -e hosts=$HOST \
                     -e path=$TARGET_PATH \
                     -v

cd  ~/e1-itis-asset/ansible/templates/$TARGET_PATH
for i in $TEMPLATES;
do 
    SRC=$i".j2"
    cp $i $SRC   

    ansible-playbook --inventory-file=../../etc/hosts \
                     --private-key=$PRIKEY \
		     ../../playbooks/deploy-template.yml \
		     -e hosts=$HOST \
                     -e src=~/e1-itis-asset/ansible/templates/$TARGET_PATH/$SRC \
                     -e dest=$TARGET_PATH/$i \
                     -v

done

cd  ~/e1-itis-asset/ansible
ansible-playbook --inventory-file=./etc/hosts \
                     --private-key=$PRIKEY \
                     ./playbooks/raw.yml \
                     -e hosts=$HOST \
                     -e 'raw="cd '$TARGET_PATH';chmod +x ./*.sh && ./install.sh"' \
                     -v
