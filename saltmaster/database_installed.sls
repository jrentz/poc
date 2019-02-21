mysql-client:
  pkg.installed

mysql_setup:
  debconf.set:
    - name: mysql-server
    - data:
        'mysql-server/root_password': {'type': 'string', 'value': 'ChangeAfter1Install'}
        'mysql-server/root_password_again': {'type': 'string', 'value': 'ChangeAfter1Install'}

mysql-server:
  pkg:
    - installed
    - require:
      - debconf: mysql_setup

