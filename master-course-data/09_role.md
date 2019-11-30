# Role による部品化
---
これまでは playbook に直接モジュールを列挙してきました。この方法でも Ansible の自動化は可能ですが、実際に Ansible を使っていくと以前の処理を再利用したくなるケースに多々遭遇します。その際に以前のコードをコピー＆ペーストするのは効率が悪いですし、かといって別の playbook 全体を呼び出そうすると `hosts:` に書かれたグループ名の整合性が取れずうまく動作しないことが保とんです。そこで登場するのが以下の図の `Role` という考え方です。

![structure.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/01/structure.png)

様々な作業単位で自動化をパーツ化して再利用可能な部品とすることができます。`Role` は完全にインベントリーと切り離されており、様々な playbook から呼び出して利用することが可能です。このような playbook の開発・管理方法を Ansible では [best practice](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html) と呼んでいます。

## Role の構造
`Role` はディレクトリ内に予め決められた構成でファイルを配置して利用します。するとそのディレクトリが `Role` として Ansible から呼び出せるようになります。

代表的なロール構造を以下に掲載します。
```
site.yml            # 呼び出す playbook
roles/              # 呼び出す playbook と同じ階層の roles ディレクトリが
                    # role が格納されていると Ansible が判断します。 
  your_role/        # your_role という role を格納するディレクトリ
                    # (ディレクトリ名 = role 名となります)
    tasks/          #
      main.yml      #  このロールの中で実施するタスクだけを記述します。
    handlers/       #
      main.yml      #  このロールの中で仕様するハンドラーだけを記述します。
    templates/      #
      ntp.conf.j2   #  このロールで利用するテンプレートを配置します。
    files/          #
      bar.txt       #  このロールの中で利用するファイルを配置します。
      foo.sh        #
    defaults/       #
      main.yml      #  このロールの中で利用する変数の一覧とデフォルト値を記述します。
                    #
  your_2nd_role/    # your_2nd_role という role。上記と同じディレクトリ構造になる。
```

上記のようなディレクトリ構造を造ったときに、`site.yml` では以下のようにロールを利用することができます。


```yaml
---
- hosts: all
  tasks:
  - import_role:
      name: your_role

  - include_role:
      name: your_2nd_role
```

このように `import_role`  `include_role` というモジュールを使ってロールの処理が呼びだせるようになります。この2つのモジュールは両方ともロールを呼出しますが、違いは以下です。

- [`import_role`](https://docs.ansible.com/ansible/latest/modules/import_role_module.html) playbook の実行前にロールを読み込む（先読み）
- [`include_role`](https://docs.ansible.com/ansible/latest/modules/include_role_module.html) タスクの実行時にロールが読み込まれる（後読み）

現時点でこの2つの使い分けは意識する必要はありません。基本的には `import_role` を使う方が安全でシンプルです。`include_role` は処理によって呼び出すロールを動的に変更するような、複雑な処理を記述するさいに利用します。

## Role の作成
---
実際にロールを作成してみます。と言っても難しいことはありません。今まで書いた処理を決められたディレクトリに分割していくだけです。

今回の演習ではWebサーバーを設定する `web_setup` ロールを作成します。以下のようなディレクトリ構造になります。
```
role_playbook.yml            # 実際にロールを呼び出す playbook
roles
└── web_setup                #
    ├── defaults
    │   └── main.yml        # 変数のデフォルト値を格納
    ├── files
    │   └── httpd.conf      # 配布するファイルを格納
    ├── handlers
    │   └── main.yml        # ハンドラーを定義
    ├── tasks
    │   └── main.yml        # タスクを記述
    └── templates
        └── index.html.j2    # テンプレートファイルを配置
```

各ファイルを作成していきます。

### `~/working/roles/web_setup/tasks/main.yml`
---
```yaml
---
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
    src: index.html.j2
    dest: /var/www/html/index.html

- name: Copy Apache configuration file
  copy:
    src: httpd.conf
    dest: /etc/httpd/conf/
  notify:
    - restart_apache
```

ロールには `play` パートを記述する必要はありませんのでタスクのみを列挙していきます。また、ロール内の `templates` `files` ディレクトリは指定しなくても、決め打ちでこのディレクトリをモジュールから参照できるようになっていますの。そのため、`copy` `template` モジュールの `src` にはファイル名しか記述されていません。

### `~/working/roles/web_setup/handlers/main.yml`
---
```yaml
---
- name: restart_apache
  service:
    name: httpd
    state: restarted
```

### `~/working/roles/web_setup/defaults/main.yml`
---
```yaml
---
LANG: JP
```

### `~/working/roles/web_setup/templates/index.html.j2`
---
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

### `~/working/roles/web_setup/files/httpd.conf`
---
このファイルはサーバー側から取得して、以下のように編集してください。

`cd ~/working/roles/web_setup`{{execute}}

`ansible node-1 -m fetch -a 'src=/etc/httpd/conf/httpd.conf dest=files/httpd.conf flat=yes'`{{execute}}

ファイルが取得できていることを確認して、以下のようにファイルを書き換えます。
`ls -l files/`{{execute}}

```
ServerAdmin root@localhost
      ↓
ServerAdmin centos_role@localhost
```

### `~/working/role_playbook.yml`
---
実際にロールを呼び出す playbook を作成します。

```yaml
---
- name: using role
  hosts: web
  become: yes
  tasks:
    - import_role:
        name: web_setup
```

### 全体の確認
---
作成したロールを確認します。

`cd ~/working`{{execute}}

`tree roles`{{execute}}

以下のような構造になっていれば必要なファイルの準備が整っています。
```bash
roles
└── web_setup
    ├── defaults
    │   └── main.yml
    ├── files
    │   ├── dummy_file  # ここは無視してください。
    │   └── httpd.conf
    ├── handlers
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    └── templates
        └── index.html.j2
```

## 実行
---
作成した playbook を実行します。

`ansible-playbook role_playbook.yml`{{execute}}

```bash
PLAY [using role] **********************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************
ok: [node-3]
ok: [node-1]
ok: [node-2]

TASK [web_setup : install httpd] *******************************************************************************************************
ok: [node-1]
ok: [node-3]
ok: [node-2]

TASK [web_setup : start & enabled httpd] ***********************************************************************************************
ok: [node-1]
ok: [node-3]
ok: [node-2]

TASK [web_setup : Put index.html from template] ****************************************************************************************
ok: [node-3]
ok: [node-2]
ok: [node-1]

TASK [web_setup : Copy Apache configuration file] **************************************************************************************
changed: [node-3]
changed: [node-2]
changed: [node-1]

RUNNING HANDLER [web_setup : restart_apache] *******************************************************************************************
changed: [node-2]
changed: [node-3]
changed: [node-1]

PLAY RECAP *****************************************************************************************************************************
node-1                     : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node-2                     : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node-3                     : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

実行に成功したら、ブラウザで各サーバーにアクセスして結果を確認してください。

ロールを使うことで飛躍的に自動化の再利用性が高まります。これはタスクとインベントリーが完全に切り離されることにも起因しますが、それ以上に自動度の高い playbook の記述方法に一定のルールを設けることで、「どこに何が定義されているのか」の見通しが良くなり、他のメンバーからも安心してロールを呼び出せるようになるからです。


## 演習の解答
---
- [role_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/role_playbook.yml)
- [web_setup](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/roles)
