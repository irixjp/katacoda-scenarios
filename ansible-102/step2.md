再利用可能な Playbook を作成していきます。

## 説明

![image2-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/ansible-101/images/image2-1.png "image2-1")




## 演習

### ステップ 1

まず最初は簡単なところで、ホストに対してpingを送ってみましょう。pingモジュールでホストの応答を確認できます。

`ansible all -m ping`{{execute}}

これは Ansible として「ping」であり、通常のICMPを使った ping とは意味が異なります。Ansible として対象に到達可能で、制御可能かを確かめる ping です。

- `-m` の後にモジュールを指定します。ここで指定している `all` というオプションは一旦気にしないでください。あとで解説を行います。

### ステップ 2

今度はcommandモジュールを使って基本的なLinuxコマンドを走らせ、その出力をフォーマットしてみます。

`ansible all -m command -a "uptime" -o`{{execute}}

- `-o` はアドホック・コマンドの出力を1ノード1行にまとめるオプションです。

### ステップ 3

利用しているノードのコンフィギュレーションを確認してみましょう。setupモジュールはAnsibleのエンドポイントの情報を表示します。

`ansible all -m setup`{{execute}}

setup という名前はややこしいですが、対象となるノードの「設定情報」を収集するためのモジュールです。実行すると大量の情報が出力されますが、これはAnsibleが対象ノードから取得した設定情報を JSON 形式で出力してくれています。


### ステップ 4

次にyumモジュールを用いてApacheをインストールしましょう。

`ansible all -m yum -a "name=httpd state=present"`{{execute}}

### ステップ 5

Apacheのインストールが終わったので、serviceモジュールを使って起動してみましょう。

`ansible all -m service -a "name=httpd state=started"`{{execute}}

これで制御対象のホストに HTTPD がインストールされて起動したはずです。コンソールの上側のある `node-1` `node-2` ... という部分をクリックしてみてください。

このリンクは、制御対象のノードのポート80へアクセスするように設定されています。設定がうまくいっていれば、Apache の初期画面が表示されるはずです。


### ステップ 6

そして最後にクリーンナップします。まず httpd サービスを停止しましょう。

`ansible all -m service -a "name=httpd state=stopped"`{{execute}}


### ステップ 7

そしてApacheパッケージを削除します。

`ansible all -m yum -a "name=httpd state=absent"`{{execute}}

