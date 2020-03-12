#Steps
PRIKEY=$1
HOST=$2
LOG=$3

cd  ~/e1-itis-asset/ansible
ansible-playbook --inventory-file=./etc/hosts \
                     --private-key=$PRIKEY \
                     ./playbooks/raw.yml \
                     -e hosts=$HOST \
                     -e 'raw="tail '$LOG'"' \
                     -v
