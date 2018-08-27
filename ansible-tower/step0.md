In order to configure this environment, exec the below command.

`bash ./lab_setup.sh`{{execute}}


`curl -O https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el7.tar.gz`{{execute}}

`tar zxvf ansible-tower-setup-bundle-latest.el7.tar.gz`{{execute}}

`cd ansible-tower-setup-bundle-*`{{execute}}

`vim inventory`{{execute}}

`/setup.sh -e required_ram=0`{{execute}}
