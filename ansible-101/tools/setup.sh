#!/bin/bash
echo "setup hands-on environments"

docker run -d --privileged --name node-1 -h node-1 -p 8081:80 centos:7 /sbin/init
docker run -d --privileged --name node-2 -h node-2 -p 8082:80 centos:7 /sbin/init
docker run -d --privileged --name node-3 -h node-3 -p 8083:80 centos:7 /sbin/init
