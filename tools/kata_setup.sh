#!/bin/bash -ex

ANSIBLE_CORE=2.11.5
ANSIBLE_LINT=5.2.0
MOLECULE=
YAML_LINT=1.26.3
DOCKER_PY=5.0.0
DOCKER_COLLECTION=1.8.0
CRYPT_COLLECTION=1.7.1
PYYAML==5.4.1

apt remove -qyy ansible python3-yaml
pip install -U pip setuptools
pip install -U --ignore-install PyYAML==${PYYAML}
pip install ansible-core==${ANSIBLE_CORE} ansible-lint==${ANSIBLE_LINT} yamllint==${YAML_LINT} docker==${DOCKER_PY}
hash -r
ansible-galaxy collection install community.docker:${DOCKER_COLLECTION}
ansible-galaxy collection install community.crypto:${CRYPT_COLLECTION}

ansible --version
ansible-galaxy collection list

ansible-playbook -i localhost, -c local kata_prepare.yml

cp -r ../materials/working /root/working
