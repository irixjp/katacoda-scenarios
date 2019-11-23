# ループ、条件式、ハンドラー
---
playbook は YAML 形式で表記するため、基本的には作業やパラメーターを「データ」として表現するためのフォーマットになります。しかし、時にはプログラミングとしての機能を用いたほうが簡潔に表現できる場合もあります。この演習では、 playbook が持つ「プログラミングとしての機能」をみていきます。

## ループ
---
特定のタスクを繰り返し実行する場合に用います。例えば、`apple`, `orange`, `pineapple` の3つOSユーザーを作成する playbook を見てみましょう。ユーザーを追加するには [`user`](https://docs.ansible.com/ansible/latest/modules/user_module.html) モジュールが利用できるので、以下のような playbook が書けます。

```yaml
---
- name: add three users individually
  hosts: node-1
  become: yes
  tasks:
    - name: add apple user
      user:
        name: apple
        state: present

    - name: add orange user
      user:
        name: orange
        state: present

    - name: add pineapple user
      user:
        name: orange
        state: present
```

この playbook は完全に意図したとおりに3つのユーザーを追加するように動作します。しかし、この方法は同じ記述を何度も繰り返す必要があり冗長的です。仮に `user` モジュールの使用が変わり、新しいパラメーターの与え方が変更されたり、各ユーザーに追加の情報をもたせたいときには、各タスクを全て編集する必要があります。このような時に利用できるのが `loop` です。

`~/working/loop_playbook.yml` を以下のように編集してください。
```yaml
---
- name: add users by loop
  hosts: node-1
  become: yes
  vars:
    user_list:
      - apple
      - orange
      - pineapple
  tasks:
    - name: add a user
      user:
        name: "{{ item }}"
        state: present
      loop: "{{ user_list }}"
```

- `vars:` 変数 `user_list` を定義して、apple, orange, pineapple という3つの要素を持つ配列を定義しています。
- `loop: "{{ user_list }}"` タスクに loop句をつけて、パラメーターに配列を与えると、要素の数分だけタスクを繰り返し実行してくれます。
- `name: "{{ item }}"` item 変数は loop の中でのみ利用できる変数で、ここに取り出された変数が格納されています。つまり、1ループ目には apple 、2ループ目には orange となります。

`loop_playbook.yml` を実行します。

`cd ~/working`{{execute}}

`ansible-playbook loop_playbook.yml`{{execute}}

```bash
(省略)
TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [add a user] ************************************
changed: [node-1] => (item=apple)
changed: [node-1] => (item=orange)
changed: [node-1] => (item=pineapple)

(省略)
```

本当にユーザーが追加されたかを確認してみましょう。正しく playbook が記述されていれば、node-1 にユーザーが作成されているはずです。

`ansible node-1 -b -m shell -a 'cat /etc/passwd'`{{execute}}

```bash
(省略)
apple:x:1001:1001::/home/apple:/bin/bash
orange:x:1002:1002::/home/orange:/bin/bash
pineapple:x:1003:1003::/home/pineapple:/bin/bash
```

さらに `mango`, `peach` ユーザーを追加したくなったとします。其の場合には、どのように playbook を編集すれば良いでしょうか。実際に playbook を編集して再度実行してください。以下のような実行結果となれば正しく記述できています。冪等性が働いていることが確認できるはずです。

`ansible-playbook loop_playbook.yml`{{execute}}

```bash
(省略)
TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [add a user] ************************************
ok: [node-1] => (item=apple)
ok: [node-1] => (item=orange)
ok: [node-1] => (item=pineapple)
changed: [node-1] => (item=mango)
changed: [node-1] => (item=peach)

(省略)
```

回答例は本ページの末尾に記載されています。

> Note: この演習では変数 `user_list` を playbook の内部で定義していますが、これを `group_vars` などのファイルに持たせることで、「ユーザーを追加する処理」と「追加されるユーザーのデータ」を分けて管理することが可能になります。

ここでは最も単純なプールを紹介しましたが、様々なケースでのループ方法が[公式ドキュメント](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html)で紹介されています。


## 条件式
---
特定の条件下でタスクを実行する・しないを制御するために用いられます。`when` 句を使います。典型的な利用方法として、あるタスクの実行結果を元に、次のタスクを実行する・しないという制御を行うケースです。

実際に以下の`~/working/when_playbook.yml` を書いてみましょう
```yaml
---
- name: start httpd if it's stopped
  hosts: node-1
  become: yes
  tasks:
    - name: check httpd processes is running
      shell: ps -ef |grep http[d]
      register: ret
      ignore_errors: yes
      changed_when: no

    - name: print return value
      debug:
        var: ret

    - name: start httpd (httpd is stopped)
      service:
        name: httpd
        state: started
      when:
        - ret.rc == 1
```

この playbook は httpd プロセスの起動状態を確かめて、もしプロセスが存在していなければ起動する、という処理になります。

> Note: 実際には冪等性が働くため、この処理は `service` 部分だけでも同じ効果となりますのであまり意味がありませんが、練習用の題材だと考えてください。

- `register: ret` ここで `ps -ef | grep http[d]` の結果を格納しています。
- `ignore_errors: yes` タスク内で発生したエラーを無視するオプションです。このコマンドはプロセスが見つからない場合にエラーとなるため、このオプションをつけないとここでタスクが停止していまします。
- `changed_when: no` このタスクが `changed` になる条件を記載します。`shell` モジュールは常に `changed` を返しますが、このオプションに `no` を指定すると `ok` を返します。
- `when:` ここに条件をリスト形式で記載します。もし複数の条件をリストで与えた場合には、AND条件となります。
  - `- ret.rc == 1` コマンド実行結果の `rc` の値を比較しています。`rc` にはコマンドラインの戻り値が格納されています。つまり、`ps -ef | grep http[d]` でプロセスが「見つからない」場合にはエラーとなり `1` がここに格納されます。

playbook を実行する前に、httpd を停止しておきます。

`ansible node-1 -b -m shell -a 'systemctl stop httpd'`{{execute}}

`~/working/when_playbook.yml` を実行します。

`ansible-playbook when_playbook.yml`{{execute}}

```bash
TASK [check httpd processes is running] **************
fatal: [node-1]: FAILED! => {"changed": false, "cmd": "ps -ef |grep http[d]", "delta": "0:00:00.023918", "end": "2019-11-18 06:07:44.403881", "msg": "non-zero return code", "rc": 1, "start": "2019-11-18 06:07:44.379963", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
...ignoring

TASK [print return value] ****************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "cmd": "ps -ef |grep http[d]",
        "delta": "0:00:00.023918",
        "end": "2019-11-18 06:07:44.403881",
        "failed": true,
        "msg": "non-zero return code",
        "rc": 1,
        "start": "2019-11-18 06:07:44.379963",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "",
        "stdout_lines": []
    }
}

TASK [start httpd (httpd is stopped)] ****************
changed: [node-1]
```

ここでは、httpd の起動タスクが `ret.rc == 1` の条件に当てはまったため実行されています。

次に、`~/working/when_playbook.yml` を再度実行します。今度は httpd が起動している状態です。

`ansible-playbook when_playbook.yml`{{execute}}

```bash
TASK [check httpd processes is running] **************
ok: [node-1]

TASK [print return value] ****************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "cmd": "ps -ef |grep http[d]",
        "delta": "0:00:00.018448",
        "end": "2019-11-18 06:08:30.779933",
        "failed": false,
        "rc": 0,
        "start": "2019-11-18 06:08:30.761485",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "root      4913     1  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4914  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4915  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4916  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4917  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4918  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
        "stdout_lines": [
            "root      4913     1  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4914  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4915  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4916  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4917  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4918  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND"
        ]
    }
}

TASK [start httpd (httpd is stopped)] ****************
skipping: [node-1]
```

今回の実行では、`ret.rc` の値が `0` となるため、条件に合致せず `skipping` となっています。

条件の記述方法などの詳細は[公式ドキュメント](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html)に更に詳細な解説があります。


## ハンドラー
---
ハンドラーは `when` 句のような条件式に似た機能ですが、より用途が限定されています。具体的には、特定のタスクが `changed` になった時に、別のタスクを起動するという動作をします。典型的な用途として、ある設定ファイルを更新した時にセットでプロセスを再起動するというケースです。

演習では、`httpd.conf` をサーバーに配布して、ファイルが更新されたら `httpd` を再起動するという playbook を作成します。

まず、配布する `httpd.conf` をサーバーから取得します。

`ansible node-1 -m fetch -a 'src=/etc/httpd/conf/httpd.conf dest=files/httpd.conf flat=yes'`{{execute}}

```bash
node-1 | CHANGED => {
    "changed": true,
    "checksum": "fdb1090d44c1980958ec96d3e2066b9a73bfda32",
    "dest": "/notebooks/solutions/files/httpd.conf",
    "md5sum": "f5e7449c0f17bc856e86011cb5d152ba",
    "remote_checksum": "fdb1090d44c1980958ec96d3e2066b9a73bfda32",
    "remote_md5sum": null
}
```

`ls -l files/`{{execute}}

```bash
total 16
-rw-r--r-- 1 jupyter jupyter 11753 Nov 18 07:40 httpd.conf
-rw-r--r-- 1 jupyter jupyter     2 Nov 17 14:35 index.html
```

- [`fetch`](https://docs.ansible.com/ansible/latest/modules/fetch_module.html) モジュールはリモートサーバーのファイルをローカルへ取得するモジュールです(`copy` モジュールの逆)

`~/working/handler_playbook.yml` を以下のように編集します。
```yaml
---
- name: restart httpd if httpd.conf is changed
  hosts: node-1
  become: yes
  tasks:
    - name: Copy Apache configuration file
      copy:
        src: files/httpd.conf
        dest: /etc/httpd/conf/
      notify:
        - restart_apache
  handlers:
    - name: restart_apache
      service:
        name: httpd
        state: restarted
```

ハンドラーは、`notify` と `handler` の2つから構成されます。

- `notify:` ハンドラーに対して `nofily` を発信することを宣言し、これ以降に実際に送信するコードを指定します。
  - `- restart_apache` 送信するコードを指定しています。
- `handlers:` ハンドラーセクションを宣言し、これ以下に送信されるコードに対応する処理を記載します。
  `- name: restart_apache`: `notify`の`restart_apache`に対応したタスクを定義します。

`~/working/handler_playbook.yml` を実行します。

`ansible-playbook handler_playbook.yml`{{execute}}

```bash
PLAY [restart httpd if httpd.conf is changed] ********

TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [Copy Apache configuration file] ****************
ok: [node-1]

PLAY RECAP *******************************************
node-1  : ok=2 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

この状態では全てのタスクは `ok` となりました。ここで `handler` は動いていません。

では、`files/httpd.conf` を編集して、コピーが `changed` になるようにします。以下のように編集してください。
```
ServerAdmin root@localhost
      ↓
ServerAdmin centos@localhost
```

再度 `~/working/handler_playbook.yml` を実行します。

`ansible-playbook handler_playbook.yml`{{execute}}

```bash
PLAY [restart httpd if httpd.conf is changed] ********

TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [Copy Apache configuration file] ****************
changed: [node-1]

RUNNING HANDLER [restart_apache] *********************
changed: [node-1]

PLAY RECAP *******************************************
node-1 : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

`httpd.conf` を更新したため、`copy` モジュールが `chaged` となりました。すると設定した `notify` が呼び出され `restart_apache` が実行されています。

このようにタスクの `changed` をトリガーに、別のタスクを実行する方法がハンドラーになります。


## 演習の解答
---
- [loop_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/loop_playbook.yml)
- [when_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/when_playbook.yml)
- [handler_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/handler_playbook.yml)

