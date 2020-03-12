ansible-playbook --inventory-file=../etc/hosts \
		 --private-key=$1 \
		 ../playbooks/deploy-template.yml \
		 -e hosts=$2 \
         -e src=$3 \
         -e dest=$4 \
         -vvvv
