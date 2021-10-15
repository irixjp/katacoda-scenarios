# (講師用)演習環境の準備
---

## 演習環境の構築
---

### ブートストラップインスタンスの起動
以下のインスタンスをAWSで起動する。

- CentOS7
- vCPU 2以上、メモリー 8GB以上、ディスク 30GB以上
- セキュリティグループで 22, 80, 8888 を開放

### 基本環境のセットアップ

```bash
yum install -y docker expect

systemctl enable docker
systemctl start docker

docker version
```

### Jupyterコンテナの起動

```bash
docker run -d -p 8888:8888 --name aitac -e PASSWORD=password irixjp/aitac-automation-jupyter:2.11.5
```

### Jupyterへアクセスしターミナルから以下を実行

```
aws configure
```

> Note: AWSの認証情報を入力。リージョンは ap-northeast-1 に、フォーマットは json にする。

動作確認

```bash
aws ec2 describe-instances --output=table --query 'Reservations[].Instances[].{id:InstanceId,ipaddr:PublicIpAddress,state:State.Name,name:Tags[?Key==`Name`].Value|[0]}'

aws ec2 describe-vpcs --output table --query "Vpcs[].[VpcId,CidrBlock,DhcpOptionsId,State,OwnerId,InstanceTenancy]"
```

ソースをコピー
```bash
cd /notebooks
git clone https://github.com/irixjp/katacoda-scenarios.git .
cd tools
```

### 環境作成の実行

`ec2_inventoy.yml` の `INSTANCE_NUM` に払い出す人数を入力する

払い出しを実行。約1hほどかかる。もしエラーとなった場合はエラー内容を確認して再実行。

```bash
ansible-playbook -i ec2_inventory.yml ec2_prepare.yml
ansible-playbook -i ec2_inventory.yml ec2_instance_create.yml -e 'DOCKERHUB_USERNAME=foo' -e 'DOCKERHUB_PASSWORD=bar'
```

- `~/jupyter_url.txt` にアクセス先の情報が格納される。
- `~/inv_teacher` に全コンテナへのアクセス情報が記載される。
- `~/inventory` に全インスタンスへのアクセス情報が記載される。

AWSの状態を確認

```bash
aws ec2 describe-instances --output=table --query 'Reservations[].Instances[].{id:InstanceId,ipaddr:PublicIpAddress,state:State.Name,name:Tags[?Key==`Name`].Value|[0]}'

aws ec2 describe-vpcs --output table --query "Vpcs[].[VpcId,CidrBlock,DhcpOptionsId,State,OwnerId,InstanceTenancy]"
```


### Ehterpad を設定

```bash
EP_USER=username
EP_PASS=password

docker run -d -p 443:8443 -p 80:8080 --name eplite -e EP_USER=${EP_USER:?} -e EP_PASS=${EP_PASS:?} irixjp/eplite:latest
```


## 演習環境の削除
---
全ての演習が終わったら、演習環境を削除してください。

```bash
cd /notebook/tools
ansible-playbook -i ec2_inventory.yml ec2_instance_delete.yml
ansible-playbook -i ec2_inventory.yml ec2_cleanup.yml
```

AWSの状態を確認

```bash
aws ec2 describe-instances --output=table --query 'Reservations[].Instances[].{id:InstanceId,ipaddr:PublicIpAddress,state:State.Name,name:Tags[?Key==`Name`].Value|[0]}'

aws ec2 describe-vpcs --output table --query "Vpcs[].[VpcId,CidrBlock,DhcpOptionsId,State,OwnerId,InstanceTenancy]"
```

実行が完了したら AWS のコンソールからインスタンスが削除されていることを確認してください。
