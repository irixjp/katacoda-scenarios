In order to configure this environment, exec the below command.


### Prepare lab environment

This operation will take 3-5min

`bash ./lab_setup.sh`{{execute}}

### Download Ansible Tower Installer

`curl -O https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el7.tar.gz`{{execute}}

`tar zxvf ansible-tower-setup-bundle-latest.el7.tar.gz`{{execute}}

`cd ansible-tower-setup-bundle-*`{{execute}}

### Edit the inventory file to configure the installer

`crudini --set inventory all:vars admin_password \'ansibleWS\'`{{execute}}

`crudini --set inventory all:vars pg_password \'ansibleWS\'`{{execute}}

`crudini --set inventory all:vars rabbitmq_password \'ansibleWS\'`{{execute}}


### Run installer

This operation will take 15-20min

`./setup.sh -e required_ram=0`{{execute}}

"Migrate the Tower database schema" phase is long.


### Check Tower working

Click the above link "Tower UI".

It's successful if you can view Tower login page.


### Get your license & setup


### Setup tower cli tools

`yum install -y ansible-tower-cli`{{execute}}

`tower-cli config username admin`{{execute}}

`tower-cli config password ansibleWS`{{execute}}

`tower-cli project list`{{execute}}


### Basic configuration for running playbook

### Run Job Template

### Override variables with Survey

