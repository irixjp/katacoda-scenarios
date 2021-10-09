演習環境の準備を行います。

画面右上にはVSCodeエディタが表示されます。表示まで少し時間がかかることがあります。

## 準備作業
---
以下のコマンドを実行して演習環境を準備します。この操作は1-2分程度で終わります(このコマンドのクリックすると自動的にターミナルへのコピーと実行が行われます)。

`mkdir -p /opt/kata-materials && cd /opt/kata-materials && git clone https://github.com/irixjp/katacoda-scenarios.git . && pip install virtualenv && virtualenv ansible && source /opt/kata-materials/ansible/bin/activate && cd tools && bash ./kata_setup.sh && cd ~/`{{execute}}

> Note: 演習用の Ansible 環境は virtualenv 内に構築されます。

## 環境の概要
---
この演習では以下のように構築された環境を利用します。`node-1`, `node-2`, `node-3` という3台のサーバーが起動しており、ここに対して Ansible を使って様々な自動操作を行っていきます。

![image0-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/kata_env.png "kata_env.png")

> Note: これらのサーバーの実体はコンテナとして起動されています。

## 補足事項
---
ターミナルの上部に `node-1`, `node-2`, `node-3` というタブがあります。ここをクリックすると、各サーバーのポート80へ接続されます。今は各ノード上で何も起動していないのでクリックしても何も起こりませんが、演習の中でこのタブを使用して ノード上に構築したHTTPサーバーへアクセスします。

> Note: 実際にはこれらのタブはホスト側のポート8081, 8082, 8083にアクセスし、そこからリダイレクトされています。 host:8081 -> node-1:80, host:8082 -> node-2:80 というアクセスになっています。

演習のステップで「ブラウザでノードにアクセスしてください」という指示があった場合には、このタブをクリックしてください。
