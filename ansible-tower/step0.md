In order to configure this environment, exec the below command.

`bash ./lab_setup.sh`{{execute}}


`curl -O https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el7.tar.gz`{{execute}}

`tar zxvf ansible-tower-setup-bundle-latest.el7.tar.gz`{{execute}}

`cd ansible-tower-setup-bundle-*`{{execute}}

`crudini --set inventory all:vars admin_password \'ansibleWS\'`{{execute}}
`crudini --set inventory all:vars pg_password \'ansibleWS\'`{{execute}}
`crudini --set inventory all:vars rabbitmq_password \'ansibleWS\'`{{execute}}

`./setup.sh -e required_ram=0`{{execute}}


- Prepare your hands-on environment
- Install Ansible Tower
- Get your license & setup
- Basic configuration for running playbook
- Run Job Template
- Override variables with Survey
