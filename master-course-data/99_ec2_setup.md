# (講師用)演習環境の準備
---

## 演習環境の構築
---

### ブートストラップインスタンスの起動
以下のインスタンスをAWSで起動する。

- CentOS7
- vCPU 2以上、メモリー 8GB以上、ディスク 30GB以上
- セキュリティグループで 22, 80, 8888 を開放

基本環境のセットアップ
```bash
yum install -y docker expect

systemctl enable docker
systemctl start docker

docker version
```

Jupyterコンテナの起動
```bash
docker run -d -p 8888:8888 --name aitac -e PASSWORD=password irixjp/aitac-automation-jupyter:latest
```

Jupyterへアクセスしターミナルから以下を実行
```
aws configure
```
> Note: AWSの認証情報を入力。リージョンは ap-northeast-1 にする。


ソースをコピー
```bash
cd ~
git clone https://github.com/irixjp/katacoda-scenarios.git .
cd master-course-data/assets/tools
```

`group_vars/all.yml` の `INSTANCE_NUM` に払い出す人数を入力する

払い出しを実行。約1hほどかかる。もしエラーとなった場合はエラー内容を確認して再実行。
```
ansible-playbook ec2_prepare.yml -e 'DOCKERHUB_USERNAME=foo' -e 'DOCKERHUB_PASSWORD=bar'
```

- `~/jupyter_url.txt` にアクセス先の情報が格納される。
- `~/inv_teacher` に全コンテナへのアクセス情報が記載される。
- `~/inventory` に全インスタンスへのアクセス情報が記載される。


Ehterpad を設定
```bash
EP_USER=username
EP_PASS=password

docker run -d -p 443:8443 -p 80:8080 --name eplite -e EP_USER=${EP_USER:?} -e EP_PASS=${EP_PASS:?} irixjp/eplite:latest
```



## 演習環境の削除
---
全ての演習が終わったら、演習環境を削除してください。

`cd ~/tools`{{execute}}

`ansible-playbook ec2_cleanup.yml`{{execute}}

実行が完了したら AWS のコンソールからインスタンスが削除されていることを確認してください。
