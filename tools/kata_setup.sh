#!/bin/bash

ANSIBLE_CORE=2.11.2
ANSIBLE_LINT=5.1.1
YAML_LINT=1.26.1
DOCKER_PY=5.0.0
DOCKER_COLLECTION=1.8.0

apt remove -qyy ansible
pip install -U pip setuptools
pip install ansible-core==${ANSIBLE_CORE} ansible-lint==${ANSIBLE_LINT} yamllint==${YAML_LINT} docker==${DOCKER_PY}
hash -r
ansible-galaxy collection install community.docker:${DOCKER_COLLECTION}
