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

More details of Tower installation show [here](https://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html).


### Run installer

This operation will take 10-20min

`./setup.sh -e required_ram=0`{{execute}}

The "Migrate the Tower database schema" phase takes a little bit long time.


### Check Tower working

Click the above link "Tower UI".

It's successful if you can view Tower login page.


### Get your license & setup

There are some ways to get Ansible Tower License.

1. Getting a free limited license from [here](https://www.ansible.com/license).
1. Getting a trial unlimited license from Red Hat.
1. Getting a commercial license from Red Hat.


### Setup tower cli tools

`yum install -y ansible-tower-cli`{{execute}}

`tower-cli config username admin`{{execute}}

`tower-cli config password ansibleWS`{{execute}}

`tower-cli project list`{{execute}}


# Basic configuration for running playbook

## Project

`tower-cli project create -n sample --organization Default --scm-type git --scm-url https://github.com/irixjp/ansible-tower-demo.git --scm-update-on-launch true --monitor`{{execute}}

## Inventory

`tower-cli inventory create -n localhost --organization Default`{{execute}}

`tower-cli host create -n localhost -i localhost --variables 'ansible_connection: local'`{{execute}}

`tower-cli inventory create -n demo-clients --organization Default`{{execute}}

`tower-cli host create -n node-1 -i demo-clients --variables 'ansible_host: 172.20.0.2'`{{execute}}

`tower-cli host create -n node-2 -i demo-clients --variables 'ansible_host: 172.20.0.3'`{{execute}}


## Credential

`tower-cli credential create -n demo-cred --organization Default --credential-type Machine --inputs='{"username": "root", "password": "password"}'`{{execute}}


## ad-hoc command test

`tower-cli ad_hoc launch --job-type run -i localhost --credential demo-cred --module-name ping --monitor`{{execute}}
`tower-cli ad_hoc launch --job-type run -i demo-clients --credential demo-cred --module-name ping --monitor`{{execute}}



## Job template

`tower-cli job_template create -n job1 --job-type run -i demo-clients --project sample --playbook utils/hostname.yml --credential demo-cred`{{execute}}

`tower-cli job launch -J job1 --monitor`{{execute}}

``{{execute}}

``{{execute}}


## Run Job Template

## Override variables with Survey

