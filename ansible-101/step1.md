Ansible のインストールを行います。

## 演習

以下のコマンド実行して、Ansible を導入します。

`yum install -y ansible`{{execute}}

これで導入は終了です。すぐに Ansible を実行することができます。

試しに以下のコマンドを実行してみましょう。

`ansible all -m ping`{{execute}}

このコマンドで、以下のような出力が確認できれば Ansible が正しく動作しています。

```
node-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
node-2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
node-3 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

では、Ansible の詳細について、実際に一つ一つ機能を確認しながら見ていきましょう。

[Back to top page](https://www.katacoda.com/irixjp)
