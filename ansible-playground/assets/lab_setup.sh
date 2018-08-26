#!/bin/bash

PASSWORD=password

yum install -y ansible ansible-lint jq

echo "[web]" > inventory

for i in 1 2 3
do
    docker run -d --security-opt label:disable --cap-add SYS_ADMIN --name node-${i} -h node-${i} -p 808${i}:80 irixjp/katacoda:latest /sbin/init
    sleep 3
    docker exec -it node-${i}  sh -c "systemctl start sshd"
    docker exec -it node-${i}  sh -c "echo ${PASSWORD:?} | passwd --stdin root"
    IPADDR=`docker inspect node-${i}  | jq -r ".[0].NetworkSettings.IPAddress"`
    echo node-${i} ansible_ssh_host=${IPADDR:?} ansible_ssh_user=root ansible_ssh_pass=${PASSWORD:?} >> inventory
done

echo "Exit!!"
