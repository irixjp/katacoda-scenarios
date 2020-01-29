# テストと確認の自動化
---
Ansible ではテストや確認作業を自動化することも可能です。特に大規模なテストや小さくても繰り返し実行されるテストや確認を自動化することで大きな効果が期待できます。

ここではテストを実行する playbook の作成方法を見ていきます。

## テストに使えるモジュール
---
はじめにテストに使えるモジュールを紹介します。

- [shell]() モジュール: 任意のコマンドを実行してその結果を回収します。
- [uri]() モジュール: 任意のURLにHTTPメソッドを発行します。
- \*\_command モジュール: 主にネットワーク機器に対して任意のコマンドを発行し、その結果を回収するモジュールです。代表例 [ios_command]() [junos_command]() など。
- [assert]() モジュール: 条件式を評価して真ならば ok を返す。
- [fail]() モジュール: 条件式を評価して真ならば failed を返す。
- [template]() モジュール: テスト結果を出力するのに用いられます。

> Note: Ansible で構築・変更した環境を、Ansible 自体を使ってテストする場合には、構築に使ったモジュールとは異なるモジュールを使ってテストを行うことが推奨です。例えば、 `copy` モジュールを使って配布したファイルの確認を `shell` モジュールを使って行う、などの方法です。


## テストの記述方法
---
これらのモジュールを利用してテストを行うには、以下のように Playbook を作成します。



`shell` で任意の確認コマンドを実行し、その結果に対して `assert` で判定を行います。

```
```


- `block ~ ignore_error`
通常 playbook はエラーが発生すると、エラーとなったタスクで停止してしまいます。設定を行う場合はこれで問題はないのですが、テストの場合には途中でテストも止まってしまうことになります。テストはエラーが発生してもしなくても最後まで実行され、全体のテスト項目のうち何件が成功・エラーなのかを把握できる必要があります。その際に `shell` で発行するコマンドを `block` でまとめて `ignore_error` してエラーを無視するように設定します。


## テストのサンプル
---





## 演習の解答
---
- [lint_ok_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/working/lint_ok_playbook.yml)
- [lint_ng_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/working/lint_ng_playbook.yml)

