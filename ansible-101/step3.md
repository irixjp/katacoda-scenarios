インベントリによる対象の設定

## 説明

![image2-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/ansible-101/images/image2-1.png "image2-1")

Ansible では「何をやるか」をモジュールを使って `Playbook` という形式で表現します。一方で、「どこに対して実行するか」は `Playbook` から切り離された `Inventory` という形式で指定します。

ここでは、この Inventory について理解をしていきます。

## 演習

現在の演習環境では `Inventory` は以下のファイルがデフォルトで使用されるように設定されています。そのため、先の演習では `all` というキーワードを指定するだけでコマンドの実行が可能となっています。`all` は「インベントリに記載されたすべてのノード」を示す特別なキーワードです。

### ステップ 1

では、自分自身のインベントリを作成してみましょう。

以下のコマンドを実行して、管理対象となるIPアドレスを確認します。

`cat ./inventory`{{execute}}

ここの、`ansible_ssh_host` で与えられている部分が対象のIPアドレスとなっています。


### ステップ 2

エディタで `my_inventory` というファイルを作成して、例のようにインベントリを作成してみましょう。

`nano my_inventory`{{execute}}

例
```
[web]
node-1 ansible_ssh_host=IP_ADDR_OF_NODE-1
node-2 ansible_ssh_host=IP_ADDR_OF_NODE-2
node-3 ansible_ssh_host=IP_ADDR_OF_NODE-3

[web1]
node-1 ansible_ssh_host=IP_ADDR_OF_NODE-1

[web2]
node-2 ansible_ssh_host=IP_ADDR_OF_NODE-2

[web3]
node-3 ansible_ssh_host=IP_ADDR_OF_NODE-3
```

`IP_ADDR_OF_NODE-1,2,3` の部分は自分の環境に合わせて読み替えてください。

- ファイルを保存するには Ctrl-o → エンター
- エディタを終了するに Ctrl-x

オリジナルのファイルと異なっていますが、気にしないでください。


### ステップ 3

ではこのインベントリを使って、アドホック・コマンドを実行しみます。

`ansible all -i my_inventory -m ping -o -u root -k`{{execute}}

実行するとパスワードの入力を求められますので `password` と入力してください。

ここで指定しているオプションは以下になります。

- `-i` でインベントリファイルを指定します。指定しない場合はデフォルトのファイルが使用されます。
- `u` で接続するユーザーを指定します。先の演習では、デフォルトで使用されるインベントリファイルにユーザーの情報が記載されていましたが、今回の `my_inventory` にはユーザー情報がないのでコマンドラインから指定しています。
- `-k` 接続するためのパスワードの入力を行います。これもデフォルトインベントリーにはパスワードが直接記載されていましたが、今回は記入がないため入力を行うようにしています。


### ステップ 4

以下のように、`all` となっていた部分を変更してコマンドを実行してみましょう。

`ansible web1 -i my_inventory -m ping -o -u root -k`{{execute}}
`ansible web2 -i my_inventory -m ping -o -u root -k`{{execute}}
`ansible web3 -i my_inventory -m ping -o -u root -k`{{execute}}

`ansible web -i my_inventory -m ping -o -u root -k`{{execute}}

`[web1]` のようにセクションを作成して、その中にノードの情報を記述することで、ノードのグループ化を行うことが可能となります。

よくある使い方として、`[web]`, `[ap]`, `[db]` のように役割ごとにグループ化しておき、処理の内容によって対象のグループを使い分けるという方法があります。
