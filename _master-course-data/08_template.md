# テンプレート
---
Ansible はテンプレート機能を備えており、動的なファイル作成が可能です。テンプレートエンジンとしては [`jinja2`](https://palletsprojects.com/p/jinja/) を利用しています。

テンプレートはとても汎用性の高い機能で、様々な状況で活用できます。アプリ用のコンフィグファイルを動的に生成して配布したり、各ノードから収集した情報を元にレポートを作成することが可能です。

## Jinja2 
---
テンプレートを利用するには2つの要素が必要になります。

- テンプレートファイル: jinja2 形式の表現が埋め込まれたファイルで、一般的に j2 拡張子を付加します。
- [`template`](https://docs.ansible.com/ansible/latest/modules/template_module.html) モジュール: コピーモジュールに似ています。src にテンプレートファイルを指定し、dest に配置先を指定すると、テンプレートファイルをコピーする際に、jinja2 部分を処理してからファイルをコピーします。

実際に作成します。`~/working/templates/index.html.j2` ファイルを作成し、中身を以下となるように編集してください。このファイルが `jinja2` テンプレートファイルになります。

```jinja2
<html><body>
<h1>This server is running on {{ inventory_hostname }}.</h1>

{% if LANG == "JP" %}
     Konnichiwa!
{% else %}
     Hello!
{% endif %}
</body></html>
```

このファイルは一見すると単純な HTML ファイルに見えますが、`{{ }}` や `{% %}` で囲われた部分が存在しています。この部分がテンプレートエンジンにより展開される `Jinja2` 表現に該当します。

- `{{ }}` 内の変数を評価し、値をカッコの場所に埋め込みます。
- `{% %}` には制御文を埋め込むことができます。

詳細な解説を行う前に、まず `~/working/template_playbook.yml` を作成して、実際にテンプレートを動かしてみましょう。以下のように `template_playbook.yml` を編集してください。

```yaml
---
- name: using template
  hosts: web
  become: yes
  tasks:
    - name: install httpd
      yum:
        name: httpd
        state: latest

    - name: start & enabled httpd
      service:
        name: httpd
        state: started
        enabled: yes

    - name: Put index.html from template
      template:
        src: templates/index.html.j2
        dest: /var/www/html/index.html
```

- `template:` テンプレートモジュールを呼び出しています。

ではこの playbook を動かしてみます。

`cd ~/working`{{execute}}

`ansible-playbook template_playbook.yml -e 'LANG=JP'`{{execute}}

```bash
(省略)
TASK [Put index.html from template] **********************
changed: [node-2]
changed: [node-3]
changed: [node-1]
(省略)
```

どのような結果になったかを確認してみましょう。以下のコマンドを実行してください。

`ansible web -m uri -a 'url=http://localhost/ return_content=yes'`{{execute}}

このコマンドは [`uri`](https://docs.ansible.com/ansible/latest/modules/uri_module.html) モジュールという HTTPリクエストを発行するモジュールを利用しています。このモジュールを使って、それぞれのノード上から `http://localhost/` へアクセスしてコンテンツを取得しています。

```bash
node-1 | SUCCESS => {
    (省略)
    "content": "<html><body>\n<h1>This server is running on node-1.</h1>\n\n<p>\n     Konnichiwa!\n</p>\n</body></html>\n",
    (省略)
    "url": "http://localhost/"
}
node-2 | SUCCESS => {
    (省略)
    "content": "<html><body>\n<h1>This server is running on node-2.</h1>\n\n<p>\n     Konnichiwa!\n</p>\n</body></html>\n",
    (省略)
    "status": 200,
    "url": "http://localhost/"
}
node-3 | SUCCESS => {
    (省略)
    "content": "<html><body>\n<h1>This server is running on node-3.</h1>\n\n<p>\n     Konnichiwa!\n</p>\n</body></html>\n",
    (省略)
    "status": 200,
    "url": "http://localhost/"
}
```

`content` キーに取得した `index.html` の内容が格納されています。この内容を確認すると、テンプレートファイル内の `{{ inventory_hostname }}` の部分はホスト名に置き換えられ、`{% if LANG == "JP" %}` の部分には「Konnichiwa!」となっていることが確認できます。

では、条件を変えて `LANG == "JP"` が成立しない場合にはどうなるか確認してください。

`ansible-playbook template_playbook.yml -e 'LANG=EN'`{{execute}}

`ansible web -m uri -a 'url=http://localhost/ return_content=yes'`{{execute}}

今度の実行では、「Hello!」と挿入されたことが確認できるはずです。

> Note: ブラウザでも各ノードにアクセスして確認してください。

このようにテンプレートを使うことで、動的にファイルの生成を行うことが可能になります。この機能はとても応用範囲が広く、設定ファイルの自動生成や設定報告書の自動作成など様々な場面で活用できます。


## Filter
---
Jinja2 の機能の一つで [`filter`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html) があります。これは `{{ }}` で変数を展開する際に利用でき、変数の値を簡易的に加工することができます。この機能は playbook 内でも利用可能です。

フィルターを利用するには `{{ var_name | filter_name }}` という形式で利用します。いつくか例をみてみましょう。


### default フィルター

変数に値が入っていない場合に、初期値を設定してくれるフィルターです。

`ansible node-1 -m debug -a 'msg={{ hoge | default("abc") }}'`{{execute}}

```bash
node-1 | SUCCESS => {
    "msg": "abc"
}
```

### upper/lower フィルター

文字列を大文字・小文字に変換するフィルターです。

`ansible node-1 -e 'str=abc' -m debug -a 'msg="{{ str | upper }}"'`{{execute}}

```bash
node-1 | SUCCESS => {
    "msg": "ABC"
}
```

### min/max フィルター

リストから最小・最大値を取り出すフィルターです。

`ansible node-1 -m debug -a 'msg="{{ [5, 1, 10] | min }}"'`{{execute}}

```bash
node-1 | SUCCESS => {
    "msg": "1"
}
```

`ansible node-1 -m debug -a 'msg="{{ [5, 1, 10] | max }}"'`{{execute}}

```bash
node-1 | SUCCESS => {
    "msg": "10"
}
```

他にも多数のフィルターが実装されていますので、状況に応じて使い分けることでより簡単に playbook が作成できるようになります。

## 演習の解答
---
- [template_html_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/block_playbook.yml)
- [index.html.j2](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/templates/index.html.j2)
