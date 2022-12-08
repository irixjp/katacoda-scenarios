# コーディング規約
---
Ansible はコーディングの自由度が高く、様々な書き方で playbook を作成することができます。しかし、この自由度が課題を生み出す場合もあります。それはチームで自動化を進める時です。個人個人が好きなように playbook を作成してしまうと、ある人はタスクに `name` をつけるが、別の人はつけないといった個人の癖も一緒に実装されてしまいます。このように個人ごとに実装内容にバラツキが生じてしまうと、品質を担保するためのコストが増加していきます。

そのためにチームに必要となるのがコーディング規約です。規約を設けることで、チームで共通した記述が可能となりスキルの平準化やレビューコストの低下に繋がります。しかし一方で、規約に準拠しているのか、というチェックも新たに必要となってしまいます。

そこで Ansible では規約準拠を自動的に確かめる方法を提供していますので、その使い方について学習してしていきます。

## Ansible Lint
---
Ansible では [ansible-lint](https://github.com/ansible/ansible-lint) というプログラムを提供しています。これは plyabook の静的解析を行い、ルール違反の記述が無いかをチェックできます。チェックするルールはデフォルトでよく使われるものが適用され、自分でルールを定義することもできます。

サンプルとして以下の2つの playbook を準備しています。

- `~/working/lint_ok_playbook.yml`
- `~/working/lint_ng_playbook.yml`

この2つの playbook はどちらも正しく実行でき、`ps -ef` の結果を出力してくれます。試しに2つを実行してください。

`cd ~/working`{{execute}}

`ansible-playbook lint_ok_playbook.yml`{{execute}}

`ansible-playbook lint_ng_playbook.yml`{{execute}}

どちらも正常に実行できたはずです。では、この2つの playbook に `ansible-lint` を適用してみます。

`ansible-lint lint_ok_playbook.yml`{{execute}}

こちらは正常終了します。

> Note: Warning が出る場合がありますが無視してください。

`ansible-lint lint_ng_playbook.yml`{{execute}}

エラー例1
```text
[502] All tasks should be named
lint_ng_playbook.yml:6
Task/Handler: shell set -o pipefail
ps -ef |grep -v grep
```

エラー例2
```text
unnamed-task: All tasks should be named
lint_ng_playbook.yml:6 Task/Handler: shell  set -o pipefail
ps -ef |grep -v grep
```

2つ目のコマンドは例のようなエラーになったはずです。上記以外のエラーも出ているはずです。

> Note: チェック内容がLintのバージョンごとに若干の差異があるためです。基本的に新しいバージョンの方が厳しくなる傾向があります。

エラーの一つとして `All tasks should be named` があり、「全てのタスクは name を保つ必要がある」という規約に違反していることがわかります。

`ansible-lint` がデフォルトでチェックするルールを確認してみましょう。以下のコマンドを実行します。

`ansible-lint -L`{{execute}}

デフォルトで多数の規約が定義されていることが確認できます。これらの規約にはタグが割り当てられており、タグを指定してまとめて適用・除外を設定することができます。

タグの一覧を確認を確認するには以下で表示されます。

`ansible-lint -T`{{execute}}

除外したいタグを `-x` オプションで指定することで、そのチェックを除外することができます。試しに `lint_ng_playbook.yml` がOKとなるようにルールを除外してlintを実行してください。エラー内容を確かめて、違反しているルールのタグを確認して `-x` に続いて指定します。

> Note: `-x` は一回のコマンドで複数回使用することが可能です。例 `ansible-lint -x unnamed-task -x yaml`

次に、ルール除外を使わずに `lint_ng_playbook.yml` がエラーとならないように playbook を修正してください。修正できたら以下を実行して結果を確かめます。

`ansible-lint lint_ng_playbook.yml`{{execute}}

## 標準以外のルールを定義する
---
標準のチェック以外にも、プロジェクトや組織独自のルールも定義できます。

独自ルールは python で定義します。`AnsibleLintRule` というクラスを継承することで簡単にルールが作成できるようになっています。

詳細は[サンプル](https://github.com/ansible/ansible-lint/blob/master/examples/rules/task_has_tag.py)を確認してください。

独自ルールには以下のようなものが定義されることになるでしょう。

- 自社で禁止している操作(コマンド)が playbook に入り込まないようにする
  - 例えば、自社で使っているルーターのファームにバグがあり、そのコマンドを実行するとスイッチがハングアップしてしまうコマンドを禁止したい場合
  - その他のコマンドを実行すると問題が発生するような危険コマンドなど。


## その他のチェックツール
---
変数の命名規則や `name` に与える文言のチェックにはより汎用的な LINT ツールである [YAMLLint](https://github.com/adrienverge/yamllint) が利用できます。必要に応じて活用してください。


## 演習の解答
---
- [lint\_ok\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/working/lint_ok_playbook.yml)
- [lint\_ng\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/working/lint_ng_playbook.yml)
