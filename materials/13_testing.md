# テストと確認の自動化
---
Ansible ではテストや確認作業を自動化することも可能です。特に大規模なテストや小さくても繰り返し実行されるテストなどの各種確認作業を自動化することで大きな効果が期待できます。

ここではテストを実行する playbook の作成方法を見ていきます。

## テストでよく使用するモジュール
---
はじめにテストでよく使用するモジュールを紹介します。もちろんこれ以外にも様々なモジュールを活用して自動テストを記述するこが可能です。

- [shell](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html) モジュール: 任意のコマンドを実行してその結果を回収します。
- [uri](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/uri_module.html) モジュール: 任意のURLにHTTPメソッドを発行します。
- \*\_command モジュール: 主にネットワーク機器に対して任意のコマンドを発行し、その結果を回収するモジュールです。
- \*\_facts/info モジュール: 主に環境の情報を取得するモジュールです。
- [assert](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/assert_module.html) モジュール: 条件式を評価して真ならば ok を返す。
- [fail](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fail_module.html) モジュール: 条件式を評価して真ならば failed を返す。
- [template](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html) モジュール: テスト結果を出力するのに用いられます。
- [validate\_argument\_spec](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/validate_argument_spec_module.html) モジュール: ロールのパラメーターを検証する。

> Note: Ansible で構築・変更した環境を、Ansible 自体を使ってテストする場合には、構築に使ったモジュールとは異なるモジュールを使ってテストを行うことが推奨です。例えば、 `copy` モジュールを使って配布したファイルの確認を `shell` モジュールを使って行うなどの方法です。


## テストの記述方法
---
Ansible でのテストでよく使われる記述パターンは、`shell`, `*_command`, `*_facts` で情報を取得し、その結果を `assert`, `fail` で判定します。

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

通常 playbook はエラーが発生すると、エラーとなったタスクで停止してしまいます。設定を行う場合はこれで問題はないのですが、テストの場合には途中でテストも止まってしまうことになります。テストはエラーが発生してもしなくても最後まで実行され、全体のテスト項目のうち何件が成功・エラーなのかを把握できる必要があります。このような場合にはテストコマンドを `block` でまとめて `ignore_error` してエラーを無視するように設定します。

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
実際にテストを作成してみます。ここで想定するテスト対象は単純な例として httpd サーバーをインストールして起動したサーバーとします。具体的には以下を実行したサーバーに対してテストを行います。

`ansible node-1 -b -m yum -a 'name=httpd state=present'`{{execute}}

`ansible node-1 -b -m systemd -a 'name=httpd state=started enabled=yes'`{{execute}}

上記をテストするために以下の確認を行うこととします。

- パッケージ httpd がインストールされていること
- プロセス httpd が存在していること(起動していること)
- サービス httpd が自動起動(enabled)になっていること

ファイル `~/working/testing_assert_playbook.yml` を以下のように編集します。

```yaml
---
- name: Test with assert
  hosts: node-1
  become: yes
  gather_facts: no
  tasks:
    - ignore_errors: yes
      block:
        - name: Is httpd package installed?
          shell: yum list installed | grep -e '^httpd\.'
          register: ret_httpd_pkg

        - name: check httpd processes is running
          shell: ps -ef |grep http[d]
          register: ret_httpd_proc

        - name: Is httpd service enabled?
          shell: systemctl is-enabled httpd
          register: ret_httpd_enabled

    - block:
        - name: Assert results
          assert:
            that:
              - ret_httpd_pkg.rc == 0
              - ret_httpd_proc.rc == 0
              - ret_httpd_enabled.rc == 0
```

- 最初の`block` では `ignore_errors` 以下で必要なテストコードを実行し、それぞれの結果を `register` しています。
- 2つ目の `block` では `assert` モジュールで結果の確認を行っています。本来ならここでの `block` は不要ですが、次の演習のために記述しておきます。

Playbookを実行します。

`cd ~/working`{{execute}}

`ansible-playbook testing_assert_playbook.yml`{{execute}}

このPlaybookは正常終了したはずです。

次にテストでエラーを発生させます。あえて httpd を停止してからテストを実行します。

`ansible node-1 -b -m systemd -a 'name=httpd state=stopped enabled=yes'`{{execute}}

`ansible-playbook testing_assert_playbook.yml`{{execute}}

今回のテストは失敗したはずです。httpd が起動していないため、 `assert` でのチェックに失敗しています。


## テスト結果のレポート作成
---
次にテスト結果をレポートとして出力します。`template` モジュールを使うのが一般的ですが、ここでは `copy` モジュールと `jinja2` 形式の表記を使ってレポート作成してみます。

先程のファイル `~/working/testing_assert_playbook.yml` を以下のように編集します。`always` 以下が追加された部分になります。

```yaml
---
- name: Test with assert
  hosts: node-1
  become: yes
  gather_facts: no
  tasks:
    - ignore_errors: yes
      block:
        - name: Is httpd package installed?
          shell: yum list installed | grep -e '^httpd\.'
          register: ret_httpd_pkg

        - name: check httpd processes is running
          shell: ps -ef |grep http[d]
          register: ret_httpd_proc

        - name: Is httpd service enabled?
          shell: systemctl is-enabled httpd
          register: ret_httpd_enabled

    - block:
        - name: Assert results
          assert:
            that:
              - ret_httpd_pkg.rc == 0
              - ret_httpd_proc.rc == 0
              - ret_httpd_enabled.rc == 0
      always:
        - name: build report
          copy:
            content: |
              # Test Reports
              ---
              | test | result |
              | ---- | ------ |
              {% for i in results %}
              | {{ i.cmd | regex_replace(query, '&#124;') }} | {{ i.rc }} |
              {% endfor %}
            dest: result_report_{{ inventory_hostname }}.md
          vars:
            results:
              - "{{ ret_httpd_pkg }}"
              - "{{ ret_httpd_proc }}"
              - "{{ ret_httpd_enabled }}"
            query: "\\|"
          delegate_to: localhost
```

- 追加した `always` でテスト結果のレポートを作成しています。このように指定することで assert が失敗してもレポートが作成されます。
  - このレポート作成では `copy` モジュールの `content` パラメーターに直接 `Jinja2` を記述することで `Markdown` 形式のファイルを作成しています。
  - `regex_replace` フィルターは正規表現で文字列を置換します。
    - ここではコマンド中に含まれる `|` を `&#124;` へと置換しています。これは結果をテーブル形式で出力するときに `|` が区切り文字となるため、実行したコマンドに含まれる `|` を別表現(`&#124;`)へと置き換えています。

テストが成功するパターンで実行してみます。そのために httpd を再起動しておきます。

`ansible node-1 -b -m systemd -a 'name=httpd state=started enabled=yes'`{{execute}}

`ansible-playbook testing_assert_playbook.yml`{{execute}}

このテストは成功するはずです。 `~/working/result_report_node-1.md` というレポートファイルが作成されているはずなので中身を確認してください(ファイルを右クリックして Markdown のプレビューモードで開いてください)

次にテストを失敗させてレポートを確認します。 httpd プロセスを停止してからテストを実行します。

`ansible node-1 -b -m systemd -a 'name=httpd state=stopped enabled=yes'`{{execute}}

`ansible-playbook testing_assert_playbook.yml`{{execute}}

テストのレポートがどのように変化したか確認してください。

## 設定レポート作成
---
先の例ではテスト結果を出力させていますが、同じような方法で設定報告書を自動生成することも可能で、実際に活用されている例も多数あります。ここでは簡単なサーバー設定レポートを作成してみます。

ファイル `working/reporting_playbook.yml` を以下のように作成します。

```yaml
---
- name: Report with Ansible
  hosts: web
  gather_facts: true
  tasks:
  - name: build report
    copy:
      content: |
        # Server Configuration Reports: {{ inventory_hostname }}
        ---
        | name | value  |
        | ---- | ------ |
        {% for key, value in ansible_default_ipv4.items() %}
        | {{ key }} | {{ value }} |
        {% endfor %}
      dest: /tmp/setting_report_{{ inventory_hostname }}.md
    delegate_to: localhost
  
  - name: concatenate reports
    assemble:
      src: /tmp
      regexp: 'setting\_report\_*'
      dest: setting_report.md
      delimiter: "\n"
    run_once: true
    delegate_to: localhost
```

- `gather_facts: true` playbook実行前に `setup` を実行させて、その結果を活用できるようにしています。
- `{% for key, value in ansible_default_ipv4.items() %}` 今回はネットワークに関する設定を取り出しています。
  - 変数 `ansible_default_ipv4` を確認するには以下を実行します。
  - `ansible node-1 -m setup -a 'filter=ansible_default_ipv4'`{{execute}}
- `assemble` モジュール: ファイルを結合するモジュールです。
- `run_once: true` このオプションが指定されると複数ホストが存在しても1台だけで実行されます。これは結合処理は1回だけ実行できれば良いからです。

`ansible-playbook testing_assert_playbook.yml`{{execute}}

実行すると `setting_report.md` というファイルが working ディレクトリに作成されるので内容を確認します(Markdownのプレビューモードで確認してください)

ここで出力されたレポートは [pandoc](https://pandoc.org/) などを使うことで html 形式 → pdf と変換できるため、もう少し見た目を整えればそのまま報告書と提出することも可能です。

また今回のようなテストを体系立てて実行する方法として、[molecule](https://github.com/ansible-community/molecule) というテストツール(フレームワーク)も準備されています。molecule を使うことで統一されたテストを実行して、品質の高い自動化を実行することが可能となります。

## 演習の解答
---
- [testing\_assert\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/materials/solutions/testing_assert_playbook.yml)
- [reporting\_playbook](https://github.com/irixjp/katacoda-scenarios/blob/materials/solutions/reporting_playbook.yml)
