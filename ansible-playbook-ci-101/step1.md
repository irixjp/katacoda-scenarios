CIを適用するPlaybookを実行します。

## 演習

以下のコマンドを実行して対象の Playbook を入手します。

`git clone https://github.com/irixjp/sd2018-ansible-ci.git`{{execute}}

このPlaybookの構造を確認します。

`cd sd2018-ansible-ci`{{execute}}

`tree .`{{execute}}

このリポジトリには1つのロール「web_svr」が保存されています。このロールに対してCIを適用していきます。


### ロールのメイン処理

このロールに準備されている処理を確認していきましょう。

`cat web_svr/tasks/main.yml`{{execute}}

このロールは実行されるとhttpdをインストールし、index.htmlを生成して、最後にhttpdをインストールします。

ではこのロールを実行してみましょう。

`ansible all -i localhost, -c local -m include_role -a 'name=web_svr tasks_from=main'`{{execute}}

実行に成功すると本サーバー上で HTTPD が起動してWEBサーバーとして動作しているはずです。ターミナル上部の「http」というリンクをクリックしてください。WEBページが表示されれば成功です。


### ロールのテスト処理

先に`main.yml`の結果を見ましたが、同じ階層に`unit_test.yml`というファイルが保存されています。こちらの中身を確認してみましょう。

`cat web_svr/tasks/unit_test.yml`{{execute}}

この`unit_test,yml`の処理は、httpdがインストールされ、index.htmlが存在し、httpdが起動しているかを確認しています。

これを実行すると以下のようになります。

`ansible all -i localhost, -c local -m include_role -a 'name=web_svr tasks_from=unit_test'`{{execute}}

先の`main.yml`が成功していれば、このテストは成功するはずです。

このテストをあえて失敗させてみます。httpdを停止してから`unit_test.yml`を実行させてみましょう。

`ansible all -i localhost, -c local -m systemd -a 'name=httpd state=stopped'`{{execute}}

`ansible all -i localhost, -c local -m include_role -a 'name=web_svr tasks_from=unit_test'`{{execute}}

今回のテストは失敗したはずです。


### ロールの正しさを確認するPlaybook

このようにロールにメインの処理とセットでその動作を確認するためのテストをあわせて実装しておくことで、いつでもロールの正しさを確認できるようになります。

`tests/test.yml`は`main.yml`と`unit_test.yml`をセットで動作させるテスト用のPlaybookです。このPlaybookがエラーなく終了すればこのロールは「正しく動作する」と言えることになります。

`cat web_svr/tests/test.yml`{{execute}}

このPlaybookを実行してみましょう。

`ansible-playbook -i localhost, -c local web_svr/tests/test.yml`{{execute}}

先程停止されたhttpdが`main.yml`から起動され、その後`unit_test.yml`が実行されるため、このPlaybookは成功するはずです。
