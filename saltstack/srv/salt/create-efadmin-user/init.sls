efadmin:
  group.present:
    - gid: 2000

  user.present:
    - fullname: efadmin
    - shell: /bin/bash
    - password: '$6$BVB2/G9u$QFe9Nza9wOW0VqO9RUStWZyEk7esdP5qYujnEGUqfi//YVtpS53ZX34G15NMrQC9LCQOETrrxb4tu1/AlSLHv0'
    - home: /home/efadmin
    - uid: 2000
    - gid_from_name: True

efadmin_sudo_file:
  file.managed:
      - name: /etc/sudoers.d/efadmin
      - source: salt://create-efadmin-user/templates/efadmin
      - user: root
      - group: root
      - mode: 644

modify_ssh_config:
  cmd.run:
    - names: 
      - sed -i  's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
  

limit_ssh_user_login:
  file.append:
    - name: /etc/ssh/sshd_config
    - text:
      - AllowUsers ubuntu efadmin@10.160.119.8 efadmin@10.163.9.240

ssh_service:
  cmd.run:
    - names:
      - service ssh reload

