copy_init_key_file:
   file.managed:
      - name: ~/ansible-client-pub-key
      - source: salt://init-ansible-client/templates/ansible-client-pub-key
      - user: root
      - group: root
      - mode: 400
add_key:
    cmd.run:
      - names:
        - grep 'itis_cw@ef.com' ~ubuntu/.ssh/authorized_keys &> /dev/null  ||  cat ~/ansible-client-pub-key >> ~ubuntu/.ssh/authorized_keys


