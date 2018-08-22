#!/bin/bash

yum install -y jq

echo "setup hands-on environments"
docker run -d --security-opt label:disable --cap-add SYS_ADMIN --name node-1  -h node-1  -p 8081:80 irixjp/katacoda:latest /sbin/init
docker run -d --security-opt label:disable --cap-add SYS_ADMIN --name node-2  -h node-2  -p 8082:80 irixjp/katacoda:latest /sbin/init
docker run -d --security-opt label:disable --cap-add SYS_ADMIN --name node-3  -h node-3  -p 8083:80 irixjp/katacoda:latest /sbin/init

docker exec -it node-1  sh -c "systemctl start sshd"
docker exec -it node-2  sh -c "systemctl start sshd"
docker exec -it node-3  sh -c "systemctl start sshd"

docker exec -it node-1  sh -c "echo password | passwd --stdin root"
docker exec -it node-2  sh -c "echo password | passwd --stdin root"
docker exec -it node-3  sh -c "echo password | passwd --stdin root"

docker inspect node-1  | jq -r ".[0].NetworkSettings.IPAddress" >  inventory
docker inspect node-2  | jq -r ".[0].NetworkSettings.IPAddress" >> inventory
docker inspect node-3  | jq -r ".[0].NetworkSettings.IPAddress" >> inventory

echo "Exit!!"
