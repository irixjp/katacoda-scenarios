#!/bin/bash

yum install -y ansible ansible-lint yamllint python-docker-py tree

ansible-playbook -i localhost, -c local kata_prepare.yml

ret=$?
if [ "$ret" == 0 ]; then
    echo "Exit! Let's proceed the next step !!"
else
    echo "Something wrong ... please try again X("
fi
