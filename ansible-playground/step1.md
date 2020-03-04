In order to configure this environment, exec the below command.

`bash ./kata_setup.sh`{{execute}}


Ansible version is below:

`ansible --version`{{execute}}


ansible.cfg is below:

`cat ~/.ansible.cfg`{{execute}}


Inventory file is below:

`cat ~/inventory`{{execute}}


This playground has three centos7 clients that is launched as docker container with privileges.

![image0-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/kata_env.png "kata_env.png")


You can access port 80 for each nodes via buttons "node-1,2,3" from the top of this console.

There are some related commands.

`ansible-lint --version`{{execute}}

`yamllint --version`{{execute}}

`git --version`{{execute}}


Sample commands:

`ansible all --list-hosts`{{execute}}

`ansible web -m ping`{{execute}}

`ansible node-1 -m shell -a 'hostname'`{{execute}}


Enjoy!!

[Back to top page](https://www.katacoda.com/irixjp)
