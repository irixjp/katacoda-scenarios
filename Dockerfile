FROM centos:7
LABEL maintainer "@irix_jp"

RUN yum clean all && yum update -y && \
    yum install -y epel-release && \
    yum install -y openssh-server openssh-clients sudo && \
    yum clean all

RUN useradd centos && \
    echo "centos  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

