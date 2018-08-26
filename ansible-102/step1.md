ループ、変数、テンプレート、ハンドラを使った実践的な Playbook を作成します。

## 解説

先の演習では Ansible の基本的な部分をご紹介しました。 この後のいくつかの演習では、Playbookに柔軟性を持たせ、そしてパワフルなものへと変えていけるよう、もう一歩踏み込んだ内容について取り上げていきます。

Ansibleの最大の利点は、taskをシンプルかつ再利用可能であることだといえます。しかし、全てのシステムが一様に同じではなく、AnsibleのPlaybookを走らせる際に少しばかり変更が必要となることも考えられます。ここで変数が登場します。
システム間の差異を変数で埋め、ポートやIPアドレス、そしてディレクトリなどの変更が出来るようにします。

そしてループを使えば同じタスクを何度でも繰り返すことができます。10のパッケージをインストールする場合などが分かりやすい例でしょう。 ループを用いれば、10回 yum モジュールの呼び出しを Playbook へ記述することなく、1つのタスクでシンプルに表現できます。

テンプレートは変数の応用です。環境の構築や運用では、様々な設定ファイルを操作することになりますが、設定ファイルには環境固有の情報が書き込まれます。これらの情報はシステムごとに異なる値が利用されますが、これを変数化しておき、予め準備したテンプレートファイルを環境に配置するときに、特定の情報を変数で置き換えてくれます。DBサーバーへの接続情報や hosts ファイルのエントリーなど多岐に渡る応用が可能な便利なモジュールです。

ハンドラはサービスのよく再起動に用います。新しい構成ファイルを用意したり、新しいパッケージをインストールしたら、サービスを再起動してそれら加えた変更が反映されるようにするはずです。これを担うのがハンドラです。何かの変更をトリガーに実行させたい処理にハンドラを用います。

変数、ループ、ハンドラに関する詳細はAnsibleのドキュメントの各々のセクションを参照してください。

変数：[Ansible Variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html)
ループ：[Ansible Loops](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html)
テンプレート：[Ansible Templates](https://docs.ansible.com/ansible/latest/modules/template_module.html)
ハンドラ：[Ansible Handlers](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#handlers-running-operations-on-change)


## 演習

では実際に Playbook を作成していきましょう。

### ステップ 1

まず、Playbook を作成して、Play パートと変数に関する情報を作成します。
この Playbook 中には、利用しているWebサーバへの追加パッケージのインストールと、Webサーバに特化したいくつかの構成が含まれています。

`vim site.yml`{{execute}}

```yaml
---
- hosts: web
    name: This is a play within a playbook
    become: yes
    vars:
      httpd_packages:
        - httpd
        - mod_wsgi
      apache_test_message: This is a test message
      apache_max_keep_alive_requests: 115
```

Taskパートを作成し、install httpd packagesと命名した新規taskを追加します。

```yaml
tasks:
    - name: install httpd packages
      yum:
        name: "{{ item }}"
        state: present
      with_items: "{{ httpd_packages }}"
      notify: restart apache service
```

- vars: この後に続いて記述されるものが変数名であることをAnsibleに伝えています
- httpd\_packages httpd_packagesと命名したリスト型（list-type）の変数を定義しています。その後に続いているのは、このパッケージのリストです
- {{ item }} この記述によってhttpdやmod_wsgiといったリストのアイテムを展開するようAnsibleに伝えています。
- with\_items: "{{ httpd\_packages }}" これがループの本体で、Ansibleに対してhttpd_packagesに含まれている全てのitemに対してこのtaskを実行するよう伝えています。
- notify: restart apache service これがハンドラ（handler）です。詳細は後で解説されます。


### ステップ 2

テンプレートによるファイルの配置とサービスの起動を行います。

すでに演習環境には2つのテンプレートファイルが配置してあります。

中身を確認してみましょう。

トップページに利用するファイル
`cat index.html.j2`{{execute}}

Apache の設定ファイル
`cat httpd.conf.j2`{{execute}}

このファイルの中に、`{{ }}` で囲われた部分をいくつか確認できるはずです。

`template` モジュールを使ってこれらのファイルをサーバーに配置する時に、`{{ }}` 部分を変数で置換することが可能です。

```yaml
- name: create site-enabled directory
    file:
      name: /etc/httpd/conf/sites-enabled
      state: directory

- name: copy httpd.conf
    template:
      src: httpd.conf.j2
      dest: /etc/httpd/conf/httpd.conf
    notify: restart apache service

- name: copy index.html
    template:
      src: index.html.j2
      dest: /var/www/html/index.html

- name: start httpd
    service:
      name: httpd
      state: started
      enabled: yes
```

- file: このモジュールを使ってファイル、ディレクトリ、シンボリックリンクの作成、変更、削除を行います。
- template: このモジュールで、jinja2テンプレートの利用と実装を指定しています。templateはFilesモジュール・ファミリの中に含まれています。その他の [file-management モジュール（英語）](https://docs.ansible.com/ansible/latest/modules/list_of_files_modules.html) についても、一度目を通しておくことをお勧めします。
- jinja2: [jinja2](https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html) は、Ansibleでテンプレートの中のfiltersのような式の中のデータを変更する場合に用います。
- service: serviceモジュールはサービスの起動、停止、有効化、無効化を行います。


### ステップ 3

ハンドラの定義と利用方法。

構成ファイルの実装や新しいパッケージのインストールなど、様々な理由でサービスやプロセスを再起動する必要が出てきます。このセクションには、Playbookへのハンドラの追加、そして意図しているtaskの後でこのハンドラを呼び出す、という2つの内容が含まれています。それではPlaybookへのハンドラの追加を見てみましょう。

ハンドラの階層（インデント）は `tasks:`, `vars:`, `become:` などと同じ階層にする必要があります。

```yaml
handlers:
    - name: restart apache service
      service:
        name: httpd
        state: restarted
        enabled: yes
```

- handler: これでplayに対してtasks:の定義が終わり、handlers:の定義が開始されたことを伝えています。これに続く箇所は、名前の定義、そしてモジュールやそのモジュールのオプションの指定のように他のtaskと変わらないように見えますが、これがハンドラの定義になります。
- notify: restart apache service …​そしてついに、この部分でハンドラが呼び出されるのです！nofify宣言は名前を使ってハンドラを呼び出します。単純明快ですね。先に書いたcopy httpd.conf task中にnotify 宣言を追加した理由がこれで理解できたと思います。


### ステップ 5

シンタックスの確認を実施してみましょう。

`ansible-playbook --syntax-check site.yml`{{execute}}

もしエラーが出る場合は、以下の Playbook を内容に差分が無いか確認してください。

```yaml
---
- hosts: web
    name: This is a play within a playbook
    become: yes
    vars:
      httpd_packages:
        - httpd
        - mod_wsgi
      apache_test_message: This is a test message
      apache_max_keep_alive_requests: 115
   
    tasks:
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
          src: httpd.conf.j2
          dest: /etc/httpd/conf/httpd.conf
          notify: restart apache service
   
      - name: copy index.html
        template:
          src: index.html.j2
          dest: /var/www/html/index.html
   
      - name: start httpd
        service:
          name: httpd
          state: started
          enabled: yes
   
    handlers:
      - name: restart apache service
        service:
          name: httpd
          state: restarted
          enabled: yes
```

### ステップ 6

実際に Playbook を実行してみましょう。

`ansible-playbook site.yml`{{execute}}

もしエラーが出る場合は、Playbook の内容を見直してください。

実行に成功したら、コンソールの上側のある `node-1` `node-2` ... という部分をクリックしてみてください。
うまくいけば `template` モジュールで配布されたトップページが確認できるはずです。

この時に、変数部分がどのように置き換えられたかも確認してください。
