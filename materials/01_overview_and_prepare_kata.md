演習環境の準備を行います。

## 準備作業
---
以下のコマンドを実行して演習環境を準備します。この操作は1-2分程度で終わります。

`mkdir -p /opt/kata-materials && cd /opt/kata-materials && git clone https://github.com/irixjp/katacoda-scenarios.git . && cd tools && bash ./kata_setup.sh && cd ~/`{{execute}}

## 環境の概要
---
この演習では以下のような環境を利用します。`node-1`, `node-2`, `node-3` という3台のサーバーが起動しており、ここに対して Ansible を使って様々な操作を行っていきます。

![image0-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/kata_env.png "kata_env.png")

## 補足事項
---
ターミナルの上部に `node-1`, `node-2` というタブがあります。ここをクリックすると、各サーバーのポート80へ接続されます。今は各ノードで何も起動していないのでクリックしても何も起こりませんが、演習の中でこのタブを使用します。

> Note: 実際にこのポートはコンテナにアクセスしており、 8081 -> node-1:80, 8082 -> node-2:80 という形のアクセスになっています。

演習のステップで「ブラウザでノードにアクセスしてください」という指示があった場合には、このタブをクリックしてください。
