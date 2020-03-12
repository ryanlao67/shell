include:
  - install-zabbix-agent.install

{%- if grains['fqdn_ip4'][0].startswith('10.163') %}
  {% set Zabbix_Server = '10.163.13.99,10.160.114.182' %}
  {% set ServerActive = '10.163.13.99' %}
{%- elif grains['fqdn_ip4'][0].startswith('10.160') %}
  {% set Zabbix_Server = '10.160.114.182,10.163.13.99' %}
  {% set ServerActive = '10.160.114.182' %}
{%- endif %}

ef_mornitor_scripts:
    file.managed:
      - name: /tmp/ef-zabbix-scripts.tar.gz
      - unless: test -e /tmp/zabbix-2.4.7.tar.gz
      - makedirs: True
      - source: salt://install-zabbix-agent/files/ef-zabbix-scripts.tar.gz
ef_mornitor_scripts_extract:
    cmd.run:
      - cwd: /tmp
      - names:
        - tar -xf /tmp/ef-zabbix-scripts.tar.gz -C /var/lib
#      - unless: test -f /tmp/ef-zabbix-scripts.tar.gz
      - require:
        - file: ef_mornitor_scripts
ef_mornitor_scripts_files:
    file.directory:
      - name: /var/lib/ef_zabbix/
      - user: zabbix
      - group: zabbix
      - dir_mode: 755
      - file_mode: 644
      - recurse:
        - user
        - group
        - mode
copy_zabbix_agent_configure_file:
    file.managed:
      - name: /etc/zabbix/zabbix_agentd.conf
      - source: salt://install-zabbix-agent/templates/ef_zabbix/zabbix_agentd.conf
      - template: jinja
      - context:
          Hostname: {{ grains['host'] }}
          zabbix_server: {{ Zabbix_Server }}
          active_mode: {{ ServerActive }}
      - user: zabbix
      - group: zabbix
      - mode: 644 
copy_zabbix_cron_job_file:
    file.managed:
      - name: /etc/cron.d/zabbix_cronjob
      - source: salt://install-zabbix-agent/templates/ef_zabbix/zabbix_cronjob
      - user: zabbix
      - group: zabbix
      - mode: 644 
copy_zabbix_sudo_file:
   file.managed:
      - name: /etc/sudoers.d/zabbix
      - source: salt://install-zabbix-agent/templates/ef_zabbix/zabbix
      - user: root
      - group: root
      - mode: 644 
zabbix-agent_service:
    cmd.run:
      - names:
        - /etc/init.d/zabbix-agent restart

