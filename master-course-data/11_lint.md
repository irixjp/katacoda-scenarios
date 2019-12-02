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

`ansible-lint lint_ng_playbook.yml`{{execute}}

```bash
[502] All tasks should be named
lint_ng_playbook.yml:6
Task/Handler: shell set -o pipefail
ps -ef |grep -v grep
```

2つ目のコマンドはエラーになったはずです。





## YAML Lint
---





## 演習の解答
---
- [galaxy_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/galaxy_playbook.yml)
- [requirements.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/roles/requirements.yml)
