# (For instructors) Preparation of Exercise Environment environment
---

## Build Exercise Environment
---

### Launch Bootstrap Instance
Start the following instances in AWS:

- CentOS7
- vCPU 2 or higher, memory 8GB or higher, disk 30GB or higher
- open to security groups 22, 80, 8888

### Setup Base Environment

```bash
yum install -y docker expect

systemctl enable docker
systemctl start docker

docker version
```

### Launch Jupyter Container

```bash
docker run -d -p 8888:8888 --name aitac -e PASSWORD=password irixjp/aitac-automation-jupyter:2.11.5
```



### Access to Jupyter and run the following from the terminal:

```
aws configure
```

> Note: Input AWS credentials.The region should be ap-northeast-1 and the format should be json.

Operation Verification

```bash
aws ec2 describe-instances --output=table --query 'Reservations[].Instances[].{id:InstanceId,ipaddr:PublicIpAddress,state:State.Name,name:Tags[?Key==`Name`].Value|[0]}'

aws ec2 describe-vpcs --output table --query "Vpcs[].[VpcId,CidrBlock,DhcpOptionsId,State,OwnerId,InstanceTenancy]"
```

Copy the source
```bash
cd /notebooks
git clone https://github.com/irixjp/katacoda-scenarios.git .
cd tools
```

### Run Environment Creation

Enter the number of instance in `INSTANCE_NUM` of `ec2_inventoy.yml` 

Performed the instance creation. It takes about an hour. If an error occurs, check the error and try again.

```bash
ansible-playbook -i ec2_inventory.yml ec2_prepare.yml
ansible-playbook -i ec2_inventory.yml ec2_instance_create.yml -e 'DOCKERHUB_USERNAME=foo' -e 'DOCKERHUB_PASSWORD=bar'
```

- `~/jupyter_url.txt` stores access destination information.
- `~/inv_teacher` Access information to all containers is provided in here.
- `~/inventory` contains access information to all instances.

Check AWS Status

```bash
aws ec2 describe-instances --output=table --query 'Reservations[].Instances[].{id:InstanceId,ipaddr:PublicIpAddress,state:State.Name,name:Tags[?Key==`Name`].Value|[0]}'

aws ec2 describe-vpcs --output table --query "Vpcs[].[VpcId,CidrBlock,DhcpOptionsId,State,OwnerId,InstanceTenancy]"
```


### Configure Ehterpad

```bash
EP_USER=username
EP_PASS=password

docker run -d -p 443:8443 -p 80:8080 --name eplite -e EP_USER=${EP_USER:?} -e EP_PASS=${EP_PASS:?} irixjp/eplite:latest
```


## Delete Exercise Environment
---
Delete the exercise environment when all exercises are complete.

```bash
cd /notebook/tools
ansible-playbook -i ec2_inventory.yml ec2_instance_delete.yml
ansible-playbook -i ec2_inventory.yml ec2_cleanup.yml
```

Check AWS Status

```bash
aws ec2 describe-instances --output=table --query 'Reservations[].Instances[].{id:InstanceId,ipaddr:PublicIpAddress,state:State.Name,name:Tags[?Key==`Name`].Value|[0]}'

aws ec2 describe-vpcs --output table --query "Vpcs[].[VpcId,CidrBlock,DhcpOptionsId,State,OwnerId,InstanceTenancy]"
```

Verify that the instance has been removed from the AWS console when the execution is complete.
