ansible-playbook --inventory-file=../etc/hosts \
		 --private-key=$1 \
		 ../playbooks/init-ansible-client.yml \
		 -e hosts=$2 -vvvv
