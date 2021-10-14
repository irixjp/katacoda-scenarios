FROM centos:8

LABEL maintainer "@irix_jp"

ENV ANSIBLE_CORE=2.11.5
ENV MOLECULE=3.5.2
ENV MOLECULE_DOCKER=1.0.2
ENV ANSIBLE_LINT=5.2.0
ENV YAML_LINT=1.26.3
ENV DOCKER_PY=5.0.0
ENV DOCKER_COLLECTION=1.8.0
ENV CRYPT_COLLECTION=1.7.1
ENV GENERAL_COLLECTION=3.8.0

RUN dnf update -y && \
    dnf install -y glibc-all-langpacks git sudo which tree jq && \
    dnf install -y epel-release && dnf install -y sshpass && \
    dnf module install -y python38:3.8/common && \
    dnf module install -y python38:3.8/build && \
    dnf module install -y nodejs:12/common && \
    alternatives --set python /usr/bin/python3 && \
    dnf clean all

RUN pip3 install -U pip setuptools && \
    pip install \
    ansible-core==${ANSIBLE_CORE} \
    molecule==${MOLECULE} \
    molecule-docker==${MOLECULE_DOCKER} \
    ansible-lint==${ANSIBLE_LINT} \
    yamllint==${YAML_LINT} \
    docker==${DOCKER_PY} \
    boto boto3 awscli yq && \
    rm -rf ~/.cache/pip

RUN ansible-galaxy collection install -p /usr/share/ansible/collections community.docker:${DOCKER_COLLECTION:?} && \
    ansible-galaxy collection install -p /usr/share/ansible/collections community.crypto:${CRYPT_COLLECTION:?} && \
    ansible-galaxy collection install -p /usr/share/ansible/collections community.general:${GENERAL_COLLECTION:?} && \
    ansible-galaxy collection install -p /usr/share/ansible/collections community.aws

RUN pip install jupyterlab jupyterlab_widgets && \
    rm -rf ~/.cache/pip

RUN useradd jupyter -m -d /jupyter && \
    mkdir -p /notebooks && \
    chown -R jupyter:jupyter /notebooks && \
    echo 'jupyter ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER jupyter
WORKDIR /jupyter

COPY --chown=jupyter:jupyter assets/.jupyter /jupyter/.jupyter
COPY --chown=jupyter:jupyter assets/.ansible.cfg /jupyter/.ansible.cfg

RUN echo "alias ls='ls --color'" >> /jupyter/.bashrc  && \
    echo "alias ll='ls -alF --color'" >> /jupyter/.bashrc

EXPOSE 8888
CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--port", "8888", "--no-browser"]
