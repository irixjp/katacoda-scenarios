#!/bin/bash

PASSWORD=password

yum install -y jq

dd if=/dev/zero of=/swap_temp seek=8191 bs=1M count=1
cp --sparse=never /swap_temp /swapfile
rm -rf /swap_temp
chmod 600 /swapfile

mkswap /swapfile
swapon /swapfile
swapon -s

for i in 1
do
    docker run -d --security-opt label:disable --cap-add SYS_ADMIN --name node-${i} -h node-${i} -p 808${i}:80 irixjp/katacoda:latest /sbin/init
    sleep 3
    docker exec -it node-${i}  sh -c "systemctl start sshd"
    docker exec -it node-${i}  sh -c "echo ${PASSWORD:?} | passwd --stdin root"
    IPADDR=`docker inspect node-${i}  | jq -r ".[0].NetworkSettings.IPAddress"`
    echo node-${i} ansible_ssh_host=${IPADDR:?} ansible_ssh_user=root ansible_ssh_pass=${PASSWORD:?} >> inventory
done

echo "Exit!!"
