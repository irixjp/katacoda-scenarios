演習環境を設定しましょう。

## Task

以下のコマンドを実行して、演習環境を準備します。この操作は1分ほどでおわります。

`bash ./lab_setup.sh'`{{execute}}

以下のコマンドでファイルの中身を確認します。

`cat ./inventory`{{execute}}

このファイルが中身が以下の例のように生成されていれば問題ありません。IPアドレスは異なる場合があります。

```
node-1 ansible_ssh_host=172.20.0.2 ansible_ssh_user=root ansible_ssh_pass=password
node-2 ansible_ssh_host=172.20.0.3 ansible_ssh_user=root ansible_ssh_pass=password
node-3 ansible_ssh_host=172.20.0.4 ansible_ssh_user=root ansible_ssh_pass=password
```
