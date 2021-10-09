#!/bin/bash -ex

ANSIBLE_CORE=2.11.5
MOLECULE=3.5.2
MOLECULE_DOCKER=1.0.2
ANSIBLE_LINT=5.2.0
YAML_LINT=1.26.3
DOCKER_PY=5.0.0

DOCKER_COLLECTION=1.8.0
CRYPT_COLLECTION=1.7.1

pip install -U pip setuptools
pip install \
    ansible-core==${ANSIBLE_CORE} \
    molecule==${MOLECULE} \
    molecule-docker==${MOLECULE_DOCKER} \
    ansible-lint==${ANSIBLE_LINT} \
    yamllint==${YAML_LINT} \
    docker==${DOCKER_PY}
hash -r
ansible-galaxy collection install community.docker:${DOCKER_COLLECTION}
ansible-galaxy collection install community.crypto:${CRYPT_COLLECTION}

ansible --version
ansible-galaxy collection list

ansible-playbook -i kata_inventory kata_prepare.yml

cp -r ../materials/working /root/working

echo "### setup complete"
ansible --version
ansible-galaxy collection list
ansible-lint --version
molecule --version
