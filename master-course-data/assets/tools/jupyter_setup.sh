#!/bin/bash -xe

# get instance public ip
PUB_IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`

# set git repo
GIT_URL=https://github.com/irixjp/aitac-automation-handson.git

# set path for a student info text file
STUDENT=student.txt

# initialize a number of students
if [ "$1" == "" ]; then
    echo "This script needs a number of student to the first argument."
    exit 1
fi
if expr "$1" : "[0-9]*$" >&/dev/null;then
    STUDENT_NUM=`seq -w 01 ${1:?}`
else
    echo "The first argument must be a number."
    exit 1
fi

# add fast repo info
function set_fast_repo () {
    rm -rf /etc/yum.repos.d/*
    curl -sL -o /etc/yum.repos.d/aitac-centos.repo https://raw.githubusercontent.com/irixjp/aitac-automation-handson/master/roles/set_fast_repo/files/aitac-centos.repo

    yum clean all
    yum repolist
}

# setup docker
function setup_docker () {
    # install docker
    yum install -y docker expect

    # enable & start docker
    systemctl enable docker
    systemctl start docker

    # wait docker start
    sleep 10
    docker version
}

# launch a docker conatainer for a student.
function jupyter_launch () {
    PORT=${1:?}
    PASS=`mkpasswd -l 12 -s 0 -d 3 -c 3 -C 3`

    docker run -d \
           -p ${PORT:?}:8888 \
           --name aitac-${PORT:?} \
           -e PASSWORD=${PASS:?} \
           irixjp/aitac-automation-jupyter:dev

    echo https://${PUB_IP:?}:${PORT:?} ${PASS:?} >> ${STUDENT:?}
}

function notebook_install () {
    PORT=${1:?}
    docker exec aitac-${PORT:?} \
           sh -c "cd /notebooks && git clone ${GIT_URL:?} ."
}

function main () {
    set_fast_repo
    setup_docker

    for i in ${STUDENT_NUM:?}
    do
        jupyter_launch 80${i:?}
    done

    for i in ${STUDENT_NUM:?}
    do
        notebook_install 80${i:?}
    done
}

main

exit 0
