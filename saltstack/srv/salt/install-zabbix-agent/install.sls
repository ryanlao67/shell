copy_deb_pkg:
    file.managed:
      - name: /tmp/zabbix-release_3.4-1+trusty_all.deb
      - source: salt://install-zabbix-agent/files/zabbix-release_3.4-1+trusty_all.deb
install_deb_pkg:
    cmd.run:
      - cwd: /tmp
      - name: 'dpkg -i zabbix-release_3.4-1+trusty_all.deb'
      - unless: dpkg -l zabbix-agent
      - require:
        - file: copy_deb_pkg
install_zabbix_agent:
    pkg.installed:
      - name: zabbix-agent
      - unless: dpkg -l zabbix-agent
install_sysstat:
    pkg.installed:
      - name: sysstat
      - unless: dpkg -l sysstat

