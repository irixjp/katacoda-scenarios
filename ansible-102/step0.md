演習環境の準備を行います。

## 作業

以下のコマンドを実行して、演習環境を準備します。この操作は1-2分程度で終わります。

`bash ./lab_setup.sh`{{execute}}

以下のコマンドで演習環境の設定ファイルの中身を確認します。

`cat ./inventory`{{execute}}

このファイルが中身が以下の例のように生成されていれば演習環境の準備は完了です。IPアドレスは異なる場合があります。

```
[web]
node-1 ansible_ssh_host=172.20.0.2 ansible_ssh_user=root ansible_ssh_pass=password
node-2 ansible_ssh_host=172.20.0.3 ansible_ssh_user=root ansible_ssh_pass=password
node-3 ansible_ssh_host=172.20.0.4 ansible_ssh_user=root ansible_ssh_pass=password
```

この演習では以下のような環境を利用します。

![image0-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/ansible-101/images/image0-1.png "image0-1")

利用する Ansible のバージョンは以下で確認できます。

`ansible --version`{{execute}}

[Back to top page](https://www.katacoda.com/irixjp)
