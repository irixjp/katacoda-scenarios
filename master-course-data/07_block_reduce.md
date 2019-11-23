# エラーハンドリング
---
playbook で一連のタスクをグループ化してまとめて `when` や `ingore_errors` を適用することができます。ここで登場するのが `block` 句です。また `block` 句にはエラーハンドリングの機能もあり、`block` 内でのエラー に対して `rescue` 句のタスクを実行する、エラーに関係なく実行する `always` 句が使えます。

## block
---
`block` 句を用いた playbook は以下のように記述できます。

`~/working/block_playbook.yml` を編集してください。
```yaml
---
- name: using block statement
  hosts: node-1
  become: yes
  tasks:
    - name: Install, configure, and start Apache
      block:
        - name: install httpd
          yum:
            name: httpd
            state: latest

        - name: start & enabled httpd
          service:
            name: httpd
            state: started
            enabled: yes

        - name: copy index.html
          copy:
            src: files/index.html
            dest: /var/www/html/
      when:
        - exec_block == 'yes'
```

- `block: ~~ when:` ここでは3つのタスクを `block` 句でまとめて、`when` 句で条件をつけています。この `block` 部分は `exec_block == 'yes'` が成立した時にまとめて実行されます。

`block_playbook.yml` を `-e 'exec_block=no'` と `yes` の場合を見てみましょう。

`cd ~/working`{{execute}}

まず、条件が成立しないケースです。

`ansible-playbook block_playbook.yml -e 'exec_block=no'`{{execute}}

```bash
TASK [install httpd] *********************************
skipping: [node-1]

TASK [start & enabled httpd] *************************
skipping: [node-1]

TASK [copy index.html] *******************************
skipping: [node-1]
```

4つのタスクがまとめてスキップされていることがわかります。次に条件が成立するケースです。

`ansible-playbook block_playbook.yml -e 'exec_block=yes'`{{execute}}

```bash
TASK [install httpd] *********************************
ok: [node-1]

TASK [start & enabled httpd] *************************
ok: [node-1]

TASK [copy index.html] *******************************
ok: [node-1]
```

`block` でグループ化された3つのタスクが実行されていることがわかります。

このように、関連するタスクをグループ化することで `when` 句などを使ってまとめて制御することが可能になります。


## rescue, always
---
`block` 句では `rescue`, `always` を利用することが可能です。

`~/working/rescue_playbook.yml` を以下のように作成してください。

```yaml
---
- name: using block, rescue, always statement
  hosts: node-1
  become: yes
  tasks:
    - block:
        - name: block task
          debug:
            msg: "message from block"

        - name: check error flag in block
          assert:
            that:
              - error_flag == 'no'

      rescue:
        - name: rescue task
          debug:
            msg: "message from rescue"

        - name: check error flag in rescue
          assert:
            that:
              - error_flag == 'no'

      always:
        - name: always task
          debug:
            msg: "message from always"
```

- `block`: メインとなる処理を記述します。
  - [`assert`](): 判定用のモジュールです。`that` で与えた条件が成立する場合に `ok` となり、条件が成立しない場合は `failed` になります。
- `rescue`: `block` 内でエラーが発生した場合に実行されます。
- `always`: 必ず実行したい処理を実行します。

この playbook では `error_flag` 変数の値が `no` の場合にはエラーとない、それ以外では正常終了します。

実際に実行して結果を確認します。まず `error_flag=no` として、正常終了させます。

`ansible-playbook rescue_playbook.yml -e 'error_flag=no'`{{execute}}

```bash
TASK [block task] ************************************
ok: [node-1] => {
    "msg": "message from block"
}

TASK [check error flag in block] *********************
ok: [node-1] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [always task] ***********************************
ok: [node-1] => {
    "msg": "message from always"
}
```

この場合、`block` 内のタスクが実行され、その後 `always` 内のタスクが実行されています。

次に、エラーが発生する場合のケースを確認します。

`ansible-playbook rescue_playbook.yml -e 'error_flag=yes'`{{execute}}

```bash
TASK [block task] ************************************
ok: [node-1] => {
    "msg": "message from block"
}

TASK [check error flag in block] *********************
fatal: [node-1]: FAILED! => {
    "assertion": "error_flag == 'no'",
    "changed": false,
    "evaluated_to": false,
    "msg": "Assertion failed"
}

TASK [rescue task] ***********************************
ok: [node-1] => {
    "msg": "message from rescue"
}

TASK [check error flag in rescue] ********************
fatal: [node-1]: FAILED! => {
    "assertion": "error_flag == 'no'",
    "changed": false,
    "evaluated_to": false,
    "msg": "Assertion failed"
}

TASK [always task] ***********************************
ok: [node-1] => {
    "msg": "message from always"
}
```

ここではまず `block` のタスクが実行されますがエラーが発生します。すると、`rescue` の処理が呼び出されています。さらに `rescue` 内でもエラーが発生しますが、 playbook は停止セずに `always` が実行されます。

このように、`block`, `rescue`, `always` を使うことで、 playbook 内のエラーハンドリングを行うことが可能となります。典型的な利用シーンとして、`rescue` で失敗時のリカバリ作業を行い、`always` で状態の報告を行うというのがあります。


## 演習の解答
---
- [block_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/block_playbook.yml)
- [rescue_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/rescue_playbook.yml)
