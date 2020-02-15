# テストと確認の自動化
---
Ansible ではテストや確認作業を自動化することも可能です。特に大規模なテストや小さくても繰り返し実行されるテストなどの各種確認作業を自動化することで大きな効果が期待できます。

ここではテストを実行する playbook の作成方法を見ていきます。

## テストに使えるモジュール
---
はじめにテストに使えるモジュールを紹介します。

- [shell](https://docs.ansible.com/ansible/latest/modules/shell_module.html) モジュール: 任意のコマンドを実行してその結果を回収します。
- [uri](https://docs.ansible.com/ansible/latest/modules/uri_module.html) モジュール: 任意のURLにHTTPメソッドを発行します。
- \*\_command モジュール: 主にネットワーク機器に対して任意のコマンドを発行し、その結果を回収するモジュールです。例 [ios_command](https://docs.ansible.com/ansible/latest/modules/ios_command_module.html) [junos_command](https://docs.ansible.com/ansible/latest/modules/junos_command_module.html) など。
- \*\_facts/info モジュール: 主に環境の情報を取得するモジュールです。例 [ec2_vol_info_module](https://docs.ansible.com/ansible/latest/modules/ec2_vol_info_module.html) [netapp_e_facts](https://docs.ansible.com/ansible/latest/modules/netapp_e_facts_module.html)
- [assert](https://docs.ansible.com/ansible/latest/modules/assert_module.html) モジュール: 条件式を評価して真ならば ok を返す。
- [fail](https://docs.ansible.com/ansible/latest/modules/fail_module.html) モジュール: 条件式を評価して真ならば failed を返す。
- [template](https://docs.ansible.com/ansible/latest/modules/template_module.html) モジュール: テスト結果を出力するのに用いられます。

> Note: Ansible で構築・変更した環境を、Ansible 自体を使ってテストする場合には、構築に使ったモジュールとは異なるモジュールを使ってテストを行うことが推奨です。例えば、 `copy` モジュールを使って配布したファイルの確認を `shell` モジュールを使って行うなどの方法です。


## テストの記述方法
---
Ansible でのテストはパターンがあり、`shell`, `\*\_command`, `\*\_facts` で情報を取得し、その結果を `assert`, `fail` で判定します。

サンプル
```yaml
- name: get command AAA result
  shell: exec AAA
  register: ret_AAA

- name: check AAA result
  assert:
    that:
      - ret_AAA.rc == 0
```

通常 playbook はエラーが発生すると、エラーとなったタスクで停止してしまいます。設定を行う場合はこれで問題はないのですが、テストの場合には途中でテストも止まってしまうことになります。テストはエラーが発生してもしなくても最後まで実行され、全体のテスト項目のうち何件が成功・エラーなのかを把握できる必要があります。その際に `shell` で発行するコマンドを `block` でまとめて `ignore_error` してエラーを無視するように設定します。

サンプル
```yaml
- ignore_errors: yes
  block:
  - name: get command AAA result
    shell: exec AAA
    register: ret_AAA

  - name: get command BBB result
    shell: exec BBB
    register: ret_BBB

  - name: get command CCC result
    shell: exec CCC
    register: ret_CCC

- name: check test results
  assert:
    that: "{{ item.failed == false }}"
  loop:
    - "{{ ret_AAA }}"
    - "{{ ret_BBB }}"
    - "{{ ret_CCC }}"
```

上記のサンプルでは結果を一括してループで判定しています。この方法は便利ですが、`register` 側で簡単に判定できるように情報を出力する必要があります。複雑な条件を設定する場合には、以下のように記述することもできます。

```yaml
- name: check test results
  assert:
    that:
      - ret_AAA.rc == 0                     # 返り値を判定
      - ret_BBB.stdout.find("string") != -1 # 出力結果に string が含まれる
      - ret_CCC.stdout.find("string") == -1 # 出力結果に string が含まれない
```
`assert` の `that` 句では条件を配列として渡すと AND 条件として扱われます。



## テストの作成
---





## 演習の解答
---
- [lint_ok_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/working/lint_ok_playbook.yml)
- [lint_ng_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/working/lint_ng_playbook.yml)

