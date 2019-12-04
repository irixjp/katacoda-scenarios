Ad-Hoc コマンドを実行しながら、Ansible の「モジュール」について理解を深めます。

## 説明

![image2-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/ansible-101/images/image2-1.png "image2-1")

Ansible ではモジュールと呼ばれる様々な部品を使って「自分のやりたいこと」を Playbook に記述していきます。モジュールは「よくある操作や手順」を部品化したものです。

Ansible は標準で多数のモジュールを持っています。以下のリンクからモジュールの標準モジュールの一覧を確認することができます。

[https://docs.ansible.com/ansible/latest/modules/modules_by_category.html](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html)

通常はこのモジュールを組み合わせて `Playbook` を記述してモジュールを利用しますが、この演習ではモジュールをコマンドラインから直接呼び出して小さな処理を実行していきます。この方法を Ansible では Ad-Hoc（アドホック）コマンドと呼びます。

まずいくつかのアドホック・コマンドを走らせてみます。Ansibleのアドホック・コマンドを利用すれば、Playbookを記述せずに多数のリモート・ノードに対して小さな仕事を実行できます。この方法はちょっとした作業を実行するのにとても便利です。

アドホックコマンドの活用例
- 全サーバーの時刻を確認する
- 全サーバーの特定パッケージのバージョンを確認する
- 全ネットワークスイッチのOSバージョンを取得する
- 全ルーターのコンフィグをバックアップする


## 演習

早速、アドホックコマンドからモジュールを動作させてみましょう。

### ステップ 1

まず最初は簡単なところで、ホストに対してpingを送ってみましょう。pingモジュールでホストの応答を確認できます。

`ansible all -m ping`{{execute}}

これは Ansible として「ping」であり、通常のICMPを使った ping とは意味が異なります。Ansible として対象に到達可能で、制御可能かを確かめる ping です。

- `-m` の後にモジュールを指定します。
- ここで指定している `all` というオプションは一旦気にしないでください。あとで解説を行います。

### ステップ 2

今度はcommandモジュールを使って基本的なLinuxコマンドを走らせ、その出力をフォーマットしてみます。

`ansible all -m command -a "uptime" -o`{{execute}}

- `-o` はアドホック・コマンドの出力を1ノード1行にまとめるオプションです。出力結果が少ない場合に結果を見やすくすることができます。


### ステップ 3

利用しているノードのコンフィギュレーションを確認してみましょう。setupモジュールは Ansible のエンドポイントの情報を表示します。

`ansible all -m setup`{{execute}}

setup という名前はややこしいですが、対象となるノードの「設定情報」を収集するためのモジュールです。実行すると大量の情報が出力されますが、これはAnsibleが対象ノードから取得した設定情報を JSON 形式で出力してくれています。

この情報を別の処理に埋め込んだり、特定処理の判定に利用することができます。


### ステップ 4

次にyumモジュールを用いてApacheをインストールしましょう。

`ansible all -m yum -a "name=httpd state=present"`{{execute}}


### ステップ 5

Apacheのインストールが終わったので、serviceモジュールを使って起動してみましょう。

`ansible all -m service -a "name=httpd state=started"`{{execute}}

これで制御対象のホストに HTTPD がインストールされて起動したはずです。

コンソールの上側のある `node-1` `node-2` ... という部分をクリックしてみてください。

このリンクは、制御対象のノードのポート80へアクセスするように設定されています。設定がうまくいっていれば、Apache の初期画面が表示されるはずです。


### ステップ 6

クリーンナップします。まず httpd サービスを停止しましょう。

`ansible all -m service -a "name=httpd state=stopped"`{{execute}}


### ステップ 7

そして最後にApacheパッケージを削除します。これで対象ノードが作業前の状態に戻りました。

`ansible all -m yum -a "name=httpd state=absent"`{{execute}}

[Back to top page](https://www.katacoda.com/irixjp)
