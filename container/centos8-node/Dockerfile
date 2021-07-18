FROM centos:8
LABEL maintainer "@irix_jp"

RUN dnf clean all && \
    dnf update -y && \
    dnf install -y epel-release && \
    dnf install -y glibc-all-langpacks openssh-server openssh-clients sudo which tree && \
    dnf clean all

RUN useradd centos && \
    echo "centos  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers && \
    su -c "ssh-keygen -f ~/.ssh/id_rsa -N ''" - centos
