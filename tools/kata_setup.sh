#!/bin/bash -ex

source ./environments

apt remove -qyy ansible
pip install -U pip setuptools
pip install ansible-core==${ANSIBLE_CORE} ansible-lint==${ANSIBLE_LINT} yamllint==${YAML_LINT} docker==${DOCKER_PY}
hash -r
ansible-galaxy collection install community.docker:${DOCKER_COLLECTION}
ansible-galaxy collection install community.crypto:${CRYPT_COLLECTION}

ansible --version
ansible-galaxy collection list

ansible-playbook -i localhost, -c local kata_prepare.yml

cp -r ../materials/working /root/working
