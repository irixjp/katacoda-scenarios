インベントリを作成して自動化の対象を制御します。

## 説明

![image2-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/ansible-101/images/image2-1.png "image2-1")

Ansible では「何をやるか」をモジュールを使って `Playbook` という形式で表現します。一方で、「どこに対して実行するか」は `Playbook` から切り離された `Inventory` というファイルで指定します。

ここでは、この Inventory について理解をしていきます。

## 演習

現在の演習環境では `Inventory` にはデフォルトで `~/inventory` ファイルを使用するように設定されています(これは `~/.ansible.cfg` で指定されています)。

そのため、先の演習では `all` というキーワードを指定するだけでコマンドの実行が可能となっています。`all` は「インベントリに記載されたすべてのノード」を示す特別なキーワードです。

### ステップ 1

では、自分自身のインベントリを作成してみましょう。

サーバーのIPアドレス等の情報を以下のコマンドを実行して確認しておきます。

`cat ./inventory`{{execute}}

ここの、`ansible_ssh_host` で与えられている部分が対象のIPアドレスになります。


### ステップ 2

エディタで `my_inventory` というファイルを作成して、例のようにインベントリを作成してみましょう。

`vim my_inventory`{{execute}}

- vi/vim が苦手な方は `nano` エディタも利用可能です。`nano my_inventory`{{execute}} で起動可能です。

例
```
[web1]
node-1 ansible_ssh_host=172.20.0.2

[web2]
node-2 ansible_ssh_host=172.20.0.3

[web3]
node-3 ansible_ssh_host=172.20.0.4

[web:children]
web1
web2
web3

[foo:children]
web1
web2

[bar:children]
web2
web3
```

`172.20.0.2, 3, 4` の部分は自分の環境に合わせて読み替えてください。
オリジナルの`~/inventory`ファイルと少し形式が違いますが気にしないでください。

- ファイルの保存方法
  - `vim` Esc :wq!、または write/quit メソッドでPlaybookを保存します。
  - `nano` Ctrl-o → エンター で保存、終了するに Ctrl-x です。

### ステップ 3

ではこのインベントリを使って、アドホック・コマンドを実行しみます。

`ansible all -i my_inventory -m ping -o -u root -k`{{execute}}

実行するとパスワードの入力を求められますので `password` と入力してください。

ここで指定しているオプションは以下になります。

- `-i` でインベントリファイルを指定します。指定しない場合はデフォルトのファイルが使用されます。
- `-u` で接続するユーザーを指定します。先の演習では、デフォルトで使用されるインベントリファイルにユーザーの情報が記載されていましたが、今回の `my_inventory` にはユーザー情報がないのでコマンドラインから指定しています。指定しない場合はAnsibleを実行したユーザーの名前が使われます。
- `-k` 接続するためのパスワードの入力を行います。これもデフォルトインベントリーにはパスワードが直接記載されていましたが、今回は記入がないため入力を行うようにしています。指定しない場合、Ansibleはパスワード無しの接続を試みます（この例では失敗します）


### ステップ 4

以下のように、`all` となっていた部分を変更してコマンドを実行してみましょう。この時に、どのノードが対象になったのかを確認してください。

`ansible web1 -i my_inventory -m ping -o -u root -k`{{execute}}

`ansible web2 -i my_inventory -m ping -o -u root -k`{{execute}}

`ansible web3 -i my_inventory -m ping -o -u root -k`{{execute}}

`ansible web -i my_inventory -m ping -o -u root -k`{{execute}}

`ansible foo -i my_inventory -m ping -o -u root -k`{{execute}}

`ansible bar -i my_inventory -m ping -o -u root -k`{{execute}}

- `[web1]` のようにセクションを作成して、その中にノードの情報を記述することで、ノードのグループ化されていることが確認できるはずです。
- [xxxx:`children`] というセクションを作ると、別のグループをまとめることも可能です。

よくある使い方として、`[web]`, `[ap]`, `[db]` のように役割ごとにグループ化しておき、処理の内容によって対象のグループを使い分けるという方法があります。

### インベントリーに関する補足情報

この演習ではインベントリーを`ini`形式で記述しています。この形式以外にもインベントリーを`YAML`で記述することも可能です。Playbookと同じ形式で管理できるようになるため、こちらを好む方も大勢います。

また、今回のPlaybookは`static`(静的)に定義されていますが、CMDBやクラウド基盤と連携して`dynamic`(動的)なインベントリーを利用することも可能です。

インベントリーに関するさらなる上にアクセスするには以下を参照してください。

- https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html
- https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html


[Back to top page](https://www.katacoda.com/irixjp)
