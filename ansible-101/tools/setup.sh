#!/bin/bash
echo "setup hands-on environments"
docker run -d --privileged --name control -h control            centos:7 /sbin/init
docker run -d --privileged --name node-1  -h node-1  -p 8081:80 centos:7 /sbin/init
docker run -d --privileged --name node-2  -h node-2  -p 8082:80 centos:7 /sbin/init
docker run -d --privileged --name node-3  -h node-3  -p 8083:80 centos:7 /sbin/init

docker exec -it control yum install -y ansible openssh-clients vim
docker exec -it node-1  sh -c "yum install -y openssh-server && systemctl start sshd"
docker exec -it node-2  sh -c "yum install -y openssh-server && systemctl start sshd"
docker exec -it node-3  sh -c "yum install -y openssh-server && systemctl start sshd"

docker exec -it node-1  sh -c "echo password | passwd --stdin root"
docker exec -it node-2  sh -c "echo password | passwd --stdin root"
docker exec -it node-3  sh -c "echo password | passwd --stdin root"

docker inspect control | jq ".[0].NetworkSettings.IPAddress"
docker inspect node-1  | jq ".[0].NetworkSettings.IPAddress"
docker inspect node-2  | jq ".[0].NetworkSettings.IPAddress"
docker inspect node-3  | jq ".[0].NetworkSettings.IPAddress"
