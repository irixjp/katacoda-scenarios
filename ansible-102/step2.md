再利用可能な Playbook を作成していきます。

## 説明

![image2-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/ansible-101/images/image2-1.png "image2-1")

これまでは Playbook に直接モジュールを列挙してきました。この方法でも Ansible の自動化は可能ですが、実際に Ansible を使い始めると以前に使った自動化を、今作っている自動化に組み込みたいシーンに多々出会います。

この方法が、図にある `Role` です。様々な作業単位で自動化をパーツ化して再利用可能な部品とすることができます。このような Playbook の開発方法を Ansible では [ベストプラクティ](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html) と呼んでいます。

といっても、難しいことはありません。これまでに書いた Playbook を分解し、予め決められたルールに従ってディレクトリにファイルを配置していくだけです。

役割ごとにディレクトリが必要なため、手動で作成するのは大変ですが、Ansible Galaxy を利用するとこの雛形を作成してくれます。


## 演習

では、実際に作成したPlaybookをリファクタリングして `Role` とし部品化していきます。

### ステップ 1

新しい Playbook を作成するためのディレクトリを作成し、そこで Ansible Galaxy を使って新しい Role を初期化していきます。

`mkdir -p ~/apache-basic-playbook/roles`{{execute}}

- `~/apache-basic-playbook` 新しい Playbook の開発ディレクトリ
- `~/apache-basic-playbook/roles` Role を格納するディレクトリ

`ansible-galaxy` コマンドで `apache-simple` と命名した新しいroleを初期化します。

`cd ~/apache-basic-playbook/roles`{{execute}}

`ansible-galaxy init apache-simple`{{execute}}。

作成されたディレクトリ構造を確認してみましょう。

`tree ~/apache-basic-playbook`{{execute}}


かなりのディレクトリが作成されているのが確認できます。それぞれに役割がありますが、すべてのファイルを編集しなければならないわけではありません。

今回は使用しないディレクトリ `files` と `tests` を削除しておきましょう。

`cd ~/apache-basic-playbook/roles/apache-simple/`{{execute}}

`rm -rf files tests`{{execute}}


### ステップ 2

新しい Playbook を作成していきます。

`cd ~/apache-basic-playbook`{{execute}}

`vim site.yml`{{execute}}

```yaml
---
- hosts: web
  name: This is my role-based playbook
  become: yes
   
  roles:
    - apache-simple
```

Task パートの代わりに `Role` パートを追加しています。ここで呼び出す role を記述しています。複数のロールを順番に呼び出す場合にはここに複数の role 名を並べていきます。

Task パートの中から role を呼び出すことも可能です。その場合は role を呼び出すモジュール [import\_role](https://docs.ansible.com/ansible/latest/modules/import_role_module.html), [include\_role](https://docs.ansible.com/ansible/latest/modules/include_role_module.html) を使用します。

この時点では、まだ role の内容は実装されていませんので、この Playbook はまだ動作しません。この後に、role の中身を徐々に組み立てていきます。


### ステップ 3

各種の変数を定義していきます。

まずは role で使われるデフォルト変数を定義します。

`vim roles/apache-simple/defaults/main.yml`{{execute}}

```yaml
---
# defaults file for apache-simple
apache_test_message: This is a test message
apache_max_keep_alive_requests: 115
```

次に role に特化した変数を定義します。

`vim roles/apache-simple/vars/main.yml`{{execute}}

```yaml
---
# vars file for apache-simple
httpd_packages:
  - httpd
  - mod_wsgi
```

ちょっと待ってください…​ いま変数を2つの場所に分けて置きませんでしたか？

ええ…​ 実はその通りです。変数は柔軟に配置することができます。例をあげてみれば：

- varsディレクトリ
- defaultsディレクトリ
- group_varsディレクトリ
- Playbookのvars:セクション配下
- コマンドラインを使い `--extra_vars` オプションで指定された全てのファイル

結論から言えば、[variable precedence（英語）](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)に目を通し、どこで変数を定義するのか、そしてどのロケーションが優先されるのかを理解する必要があります。融通が利くように、この演習ではrole defaultsを利用していくつかの変数を定義しています。 それに続いて、role defaultsよりも高い優先性を持ち、デフォルトの変数をオーバーライドできる/varsにいくつかの変数を定義しています。


### ステップ 4

role のハンドラを作成します。

`vim roles/apache-simple/handlers/main.yml`{{execute}}

```yaml
---
# handlers file for apache-simple
- name: restart apache service
  service:
    name: httpd
    state: restarted
    enabled: yes
```


### ステップ 5

role に tasks を定義します。

`vim roles/apache-simple/tasks/main.yml`{{execute}}

```yaml
---
# tasks file for apache-simple
  - name: install httpd packages
    yum:
      name: "{{ item }}"
      state: present
    with_items: "{{ httpd_packages }}"
    notify: restart apache service

  - name: create site-enabled directory
    file:
      name: /etc/httpd/conf/sites-enabled
      state: directory

  - name: copy httpd.conf
    template:
      src: templates/httpd.conf.j2
      dest: /etc/httpd/conf/httpd.conf
    notify: restart apache service

  - name: copy index.html
    template:
      src: templates/index.html.j2
      dest: /var/www/html/index.html

  - name: start httpd
    service:
      name: httpd
      state: started
      enabled: yes
```

### ステップ 6

テンプレートで使用するファイルを role に配置します。

`cp ~/index.html.j2 roles/apache-simple/templates/`{{execute}}

`cp ~/httpd.conf.j2 roles/apache-simple/templates/`{{execute}}


### ステップ 7

最後にいくつかの必要なファイルをコピーしておきます。

`cp ~/inventory ~/apache-basic-playbook`{{execute}}

`cp ~/ansible.cfg ~/apache-basic-playbook`{{execute}}

ここまでの作業結果を確認しておきましょう。

`tree ~/apache-basic-playbook`{{execute}}


シンタックスの確認を実施してみましょう。

`ansible-playbook --syntax-check site.yml`{{execute}}

もしエラーが出る場合は、ここまでの作業結果を確認してください。特に、`yml` ファイルのインデントに間違いがないかは注意深く確認してください。


### ステップ 8

実行！

`ansible-playbook site.yml`{{execute}}

エラーなく終了したら、正しく HTTPD が起動されたかを確認してみてください。

次に、変数を上書きして実行してみましょう。

`ansible-playbook site.yml -e apache_test_message=vars_from_extra`{{execute}}

終了したら再び、各ノードのページを表示してみましょう。どのように表示されているでしょうか。



本演習は以上となります。

[Back to top page](https://www.katacoda.com/irixjp)
