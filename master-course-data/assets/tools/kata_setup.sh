#!/bin/bash

yum install -y ansible python-docker-py

ansible-playbook -i localhost, -c local kata_prepare.yml

echo "Exit!!"
