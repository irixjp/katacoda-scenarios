In order to configure this environment, exec the below command.

`bash ./lab_setup.sh`{{execute}}


Ansible version is below:

`ansible --version`{{execute}}


Inventory file is below:

`cat ./inventory`{{execute}}

This playground has three centos7 clients that is launched as docker container with privileges.

![image0-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/ansible-101/images/image0-1.png "image0-1")


ansible.cfg is below:

`cat ansible.cfg`{{execute}}


Test commands:

`ansible web -m ping -o`{{execute}}

`ansible localhost -m shell -a 'uname -a' -o`{{execute}}

`ansible web -m shell -a 'uname -a' -o`{{execute}}
