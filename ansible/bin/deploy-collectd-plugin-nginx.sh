#Steps
PRIKEY=$1
HOST=$2
TARGET_PATH="EC2-Linux-Collectd"
cd ~/e1-itis-asset
#1
git pull origin master

cd  ~/e1-itis-asset/ansible
ansible-playbook --inventory-file=./etc/hosts \
                     --private-key=$PRIKEY \
                     ./playbooks/raw.yml \
                     -e hosts=$HOST \
                     -e 'raw="cd '$TARGET_PATH';chmod +x ./install.nginx.sh && ./install.nginx.sh"' \
                     -v
