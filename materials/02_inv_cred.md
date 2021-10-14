# Ansible の基礎、インベントリー、認証情報
---
Ansible の基本となるインベントリー(inventory)と認証情報(credential)について学習します。これは Ansible を動かす上で最低限準備する3つの情報のうちの2つに該当します。

![structure.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/structure.png)

## 演習環境での Ansible の実行
---
まず以下のコマンドを実行してください。これは Ansible を使って3台の演習ノードのディスク使用量を確認しています。

`cd ~/`{{execute}}

`ansible all -m shell -a 'df -h'`{{execute}}

```text
node-1 | CHANGED | rc=0 >>
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       10G  885M  9.2G   9% /
devtmpfs        473M     0  473M   0% /dev
tmpfs           495M     0  495M   0% /dev/shm
tmpfs           495M   13M  482M   3% /run
tmpfs           495M     0  495M   0% /sys/fs/cgroup
tmpfs            99M     0   99M   0% /run/user/1000

node-2 | CHANGED | rc=0 >>
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       10G  885M  9.2G   9% /
devtmpfs        473M     0  473M   0% /dev
tmpfs           495M     0  495M   0% /dev/shm
tmpfs           495M   13M  482M   3% /run
tmpfs           495M     0  495M   0% /sys/fs/cgroup
tmpfs            99M     0   99M   0% /run/user/1000

node-3 | CHANGED | rc=0 >>
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvda1       10G  885M  9.2G   9% /
devtmpfs        473M     0  473M   0% /dev
tmpfs           495M     0  495M   0% /dev/shm
tmpfs           495M   13M  482M   3% /run
tmpfs           495M     0  495M   0% /sys/fs/cgroup
tmpfs            99M     0   99M   0% /run/user/1000
```

> Note: 実際の出力内容と上記の出力例の差分は無視してください。重要なのは `df -h` が実行されたということです。

これで3台のノードからディスク使用量の情報が取得できました。しかし、この3台のノードはどのように決定されたのでしょうか。もちろんこれは演習用に予め設定されているものですが、その情報は Ansible のどこに設定されているか疑問を持つ方もいるはずです。今からその設定について確認していきます。

## ansible.cfg
---
まず以下のコマンドを実行します。

`ansible --version`{{execute}}

```text
ansible [core 2.11.5] 
  config file = /root/.ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /opt/kata-materials/ansible/lib/python3.8/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /opt/kata-materials/ansible/bin/ansible
  python version = 3.8.10 (default, Sep 28 2021, 16:10:42) [GCC 9.3.0]
  jinja version = 3.0.2
  libyaml = True
```

> Note: 出力内容は環境によって異なる場合があります。

ansible コマンドに `--version` オプションをつけると、実行環境に関する基本的な情報が出力されます。バージョンや利用している Python のバージョンなどです。ここでは以下の行に注目します。

- `config file = /root/.ansible.cfg`

> Note: jupyter labs 上で演習を実施している場合は `/jupyter/.ansible.cfg` となります。以降の演習でも /root は /jupyter と読み替えてください。

これは、このディレクトリで ansible コマンドを実行した際に読み込まれる Ansible の設定ファイルのパスを表示しています。このファイルは Ansible の基本的な挙動を制御するための設定ファイルです。

「このディレクトリで実行したとき」という表現をつけましたが、 Ansible は ansible.cfg を検索する順番が決まっています。詳細は [Ansible Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#the-configuration-file) に記載されています。

簡単に説明すると、ansible.cfg は環境変数で与えられたパス、現在のディレクトリ、ホームディレクトリ、OS全体の共通パスという順序で検索され、今回はホームディレクトリ `~/.ansible.cfg` が最初に見つかるため、このファイルが利用されています。

この中身を確認してみましょう。

`cat ~/.ansible.cfg`{{execute}}

```ini
[defaults]
inventory         = /root/inventory_file
host_key_checking = False
force_color       = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
```


いくつかの設定が演習用に設定されています。ここで重要となるのが以下の設定です。

- `inventory         = /root/inventory_file`

これは、Ansible が自動化の実行対象を決定する「インベントリー」に関する設定です。

次のこの設定について詳しくみていきましょう。

## インベントリー
---
インベントリーは Ansible が自動化の実行対象を決定するための機能です。ファイルの中身を確認してみましょう。

`cat ~/inventory_file`{{execute}}

```text
[web]
node-1 ansible_host=3.114.16.114
node-2 ansible_host=3.114.209.178
node-3 ansible_host=52.195.15.8

[all:vars]
ansible_user=centos
ansible_ssh_private_key_file=/root/aitac-automation-keypair.pem
```

> Note: 演習環境によっては `http_access=http://35.73.128.87:8083` のような出力がされる場合がありますが、気にせず進めてください。

このインベントリーは `ini` ファイル形式で記述されています。他にも `YAML` 形式や、スクリプトで動的にインベントリーを構成する `ダイナミックインベントリー` という仕組みもサポートされています。詳細は [How to build your inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html) を確認してください。

このインベントリーファイルは以下のルールで記述されています。

- `node-1` `node-2` のように1行1ノードで情報を記述します。
  - ノード行は `ノードの識別子(node-1)`、ノードに与える`ホスト変数(複数可) (ansible_host=xxxx)` から構成されます。
  - `node-1` の部分にはIPアドレスやFQDNを指定することも可能です。
- `[web]` でホストのグループを作ることができます。ここでは `web` というグループが作られます。
  - グループ名は `all` と `localhost` 以外の名前を自由に使用できます。
    - 例) `[web]` `[ap]` `[db]` などシステムをグループ分けする目的で使用されます。
- `[all:vars]` では、`all` というグループに対して `グループ変数` を定義しています。
  - `all` は特別なグループで、インベントリーに記述された全ノードを指し示すグループです。
  - ここで与えられている、 `ansible_user` `ansible_ssh_private_key_file` は特別な変数で、各ノードへのログインに使われるユーザー名とSSH秘密鍵のパスを示しています。
    - `ansible_xxxx` という[マジック変数](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html)で、Ansible の挙動を制御したり、Ansible が自動的に取得する環境情報など特別な値が格納されています。詳細は変数の項目で解説します。

実際にこのインベントリーを利用して定義されたノードの対して Ansible を実行してみます。以下のコマンドを実行してください。

`ansible web -i ~/inventory_file -m ping -o`{{execute}}

```text
node-3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
node-2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
```

このコマンドのオプションの意味は以下になります。

- `web`: インベントリー内のグループを指定しています。
- `-i ~/inventory`: 利用するインベントリーファイルを指定します。
- `-m ping`: モジュール `ping` を実行します。モジュールに関しての詳細は後述します。
- `-o`: 出力を1ノード1行にまとめます。

今回の環境では、 `ansible.cfg` ファイルによって、デフォルトのインベントリーが指定されているため、以下のように `-i ~/inventory_file` を省略することが可能です。

`ansible web -m ping -o`{{execute}}

```text
node-3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
node-2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
```

> Note: 以降の演習では、上記のようにインベントリーの指定は省略します。

グループ名の代わりにノード名を指定することも可能です。

`ansible node-1 -m ping -o`{{execute}}

```text
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
```

複数のノードを指定することも可能です。

`ansible node-1,node-3 -m ping -o`{{execute}}

```text
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
node-3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
```

特別なグループである `all` を指定してみます。`all` はインベントリーに含まれる全てのノードを対象とします。今回のインベントリーは `all` と `web` のグループが同じものを指しているため、結果も同じになります。

`ansible all -m ping -o`{{execute}}

```text
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
node-2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
node-3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"},"changed": false,"ping": "pong"}
```

ここまでの例では指定したグループに対して Ansible が何らかの処理(この場合は ping)を実行していますが、処理を行わずに対象のノードのみを確認するこも可能です。その場合は `--list-hosts` オプションを使います。

`ansible web --list-hosts`{{execute}}

```text
  hosts (3):
    node-1
    node-2
    node-3
```

`ansible node-2 --list-hosts`{{execute}}

```text
  hosts (1):
    node-2
```


## 認証情報
---
上記のインベントリーの確認では、3台のノードに対して `ping` モジュールを実行しました。このモジュールは実際にノードに対してログインを行い、Ansible が実行可能な状態かを調べています。このときにログインに使われる Credential (認証情報) について見ていきます。

> Note: ネットワークで利用するICMPを送信する ping コマンドとは完全に異なるものです。Ansibleの文脈での `ping` を実行しています。

今回の演習環境では、先に見たインベントリーの中で認証情報が指定されています。以下が抜粋となります。

```ini
[all:vars]
ansible_user=centos
ansible_ssh_private_key_file=/root/aitac-automation-keypair.pem
```

ここでは、全てのグループに対する変数として `[all:vars]` を定義し、そこで認証に利用する変数を定義しています。

- `ansible_user`: Ansible がログインに利用するユーザー名を指定する。
- `ansible_ssh_private_key_file`: Ansible がログインに利用する秘密鍵を指定する。

今回の演習では秘密鍵を用いていますが、ログインにパスワードを指定することも可能です。

- `ansible_password`: Ansible がログインに使用するパスワードを指定する。

この他にも認証情報を与える方法がいくつか提供されいます。代表的なものとしてコマンドラインのオプションとして与える方法があります。

`ansible all -u centos --private-key ~/aitac-automation-keypair.pem -m ping`{{execute}}

- `-u centos`: ログインに使用するユーザー名を指定できます。
- `--private-key`: ログインに使用する秘密鍵を指定できます。

パスワードを使用する方法もあります。以下がサンプルになります。

```text
$ ansible all -u centos -k -m ping
SSH password:  ← ここでパスワード入力を求められる
node-1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node-2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
node-3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

> Note: 本演習環境ではインベントリーファイルに秘密鍵が設定されているため、鍵認証が優先されて誤ったパスワードを入力しても操作は成功します。

- `-k`: コマンド実行時に、パスワード入力のプロンプトを出す。

Ansible に認証情報を渡す仕組みは、他にもいくつかの方法があります。本演習では最もベーシックでお手軽な手段(変数で直接指定)を用いていますが、実際に本番で利用する際には、認証情報をどう扱うかは事前に熟慮が必要です。当然ですが、ファイルに直接書かれた認証情報はそのファイルにアクセスできる全ての人が別の用途（不正にサーバーを操作するなど）で利用できてしまうためです。

一般的には、[Ansible Automation Platform](https://www.redhat.com/ja/technologies/management/ansible) や [AWX](https://github.com/ansible/awx) 等の自動化プラットフォームソフトウェアと組み合わせて使う方法がよく採用されます。
