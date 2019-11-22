# 変数
---
変数を利用することで playbook の汎用性を高めることができます。

## 変数の基礎
---
Ansible における変数は以下の特性を持っています。

- 型がない
- 全てグルーバル変数（スコープがない）
- 様々な場所で定義/上書きできる

全てグローバル変数でかつ様々な方法で定義・上書きできるため命名規則などでチーム内での利用方針を定めておくなどの工夫をすると利便性が向上します。

変数がどこで定義できて、どのような優先順位を持っているかは[公式ドキュメント](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)を参照してください。

この演習では代表的な変数の利用方法について学習します。

## debug モジュール
---
定義した変数の中身を確認するはに [`debug`](https://docs.ansible.com/ansible/latest/modules/debug_module.html) モジュールが便利です。

`working/vars_debug_playbook.yml` を以下のように編集してください。
```yaml
---
- hosts: node-1
  gather_facts: no
  tasks:
    - name: print all variables
      debug:
        var: vars

    - name: get one variable
      debug:
        msg: "This value is {{ vars.ansible_version.full }}"
```

- `gather_facts: no` Ansible はデフォルトでタスクの実行前に `setup` モジュールを実行して、操作対象ノードの情報を収集して変数にセットします。この変数を `no` に設定することで情報収集をスキップします。これは、演習の中で変数の一覧の出力量を抑えて演習を進めやすくするためです(setupモジュールは膨大な情報を収集するためです)。
- `- debug:`
  - `var: vars` var オプションは引数で与えられた変数の内容を標示します。ここでは `vars` という変数を引数として与えています。`vars` は全ての変数が格納された特別な変数です。
  - `msg: "This value is {{ vars.ansible_version.full }}"` msg オプションは任意の文字列を出力します。この中では `{{ }}` でくくった箇所は変数として展開されます。
    - 変数内の辞書データは `.keyname` という形で取り出します。
    - 変数内の配列データは `[index_number]` という形で取り出します。

`vars_debug_playbook.yml` を実行します。

`cd ~/working`{{execute}}

`ansible-playbook vars_debug_playbook.yml`{{execute}}

```bash
PLAY [node-1] ****************************************

TASK [print all variables] ***************************
ok: [node-1] => {
    "vars": {
        (省略)
        "ansible_ssh_private_key_file": "/jupyter/aitac-automation-keypair.pem",
        "ansible_user": "centos",
        "ansible_verbosity": 0,
        "ansible_version": {
            "full": "2.9.0",
            "major": 2,
            "minor": 9,
            "revision": 0,
            "string": "2.9.0"
        },
        (省略)

TASK [get one variable] ******************************
ok: [node-1] => {
    "msg": "This value is 2.9.0"
}
(省略)
```

`vars` の内容は Ansible がデフォルトで定義した、いわゆる [マジック変数](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html) です。


## playbook 内での定義
---
では実際に変数の定義を行ってみましょう。

`working/vars_play_playbook.yml` を以下のように編集します。
```yaml
---
- hosts: node-1
  gather_facts: no
  vars:
    play_vars:
      - order: 1st word
        value: ansible
      - order: 2nd word
        value: is
      - order: 3rd word
        value: fine
  tasks:
    - name: print play_vars
      debug:
        var: play_vars

    - name: access to the array
      debug:
        msg: "{{ play_vars[1].order }}"

    - name: join variables
      debug:
        msg: "{{ play_vars[0].value}} {{ play_vars[1].value }} {{ play_vars[2].value }}"
```

- `vars:` play パートに `vars:` セクションを記述すると、その配下で変数が定義できるようになります。
  - `play_vars:` 変数名です。自由に設定できます。
    - この変数の値として、3つの要素を持つ配列を作成し、その1つずつに`order` `value` というキーを持つ辞書データを持たせています。

`vars_play_playbook.yml` を実行します。

`cd ~/working`{{execute}}

`ansible-playbook vars_play_playbook.yml`{{execute}}

```bash
(省略)
TASK [print play_vars] **************
ok: [node-1] => {
    "play_vars": [
        {
            "order": "1st word",
            "value": "ansible"
        },
        {
            "order": "2nd word",
            "value": "is"
        },
        {
            "order": "3rd word",
            "value": "fine"
        }
    ]
}

TASK [access to the array] **********
ok: [node-1] => {
    "msg": "2nd word"
}

TASK [join variables] ***************
ok: [node-1] => {
    "msg": "ansible is fine"
}
(省略)
```


## task 内での定義
---
1つのタスク内だけで使う変数を定義したり、一時的に上書きを行うことが可能です。

`working/vars_task_playbook.yml` を以下のように編集します。
```yaml
---
- hosts: node-1
  gather_facts: no
  vars:
    task_vars: 100
  tasks:
    - name: print task_vars 1
      debug:
        var: task_vars

    - name: override task_vars
      debug:
        var: task_vars
      vars:
        task_vars: 20

    - name: print task_vars 2
      debug:
        var: task_vars
```

`vars_task_playbook.yml` を実行します。

`cd /notebooks/working`{{execute}}

`ansible-playbook vars_task_playbook.yml`{{execute}}

```bash
(省略)
TASK [print task_vars 1] ************
ok: [node-1] => {
    "task_vars": 100
}

TASK [override task_vars] ***********
ok: [node-1] => {
    "task_vars": 20
}

TASK [print task_vars 2] ************
ok: [node-1] => {
    "task_vars": 100
}
```

タスクの中での `vars:` 、はそのタスク内でのみ [変数の優先順位](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) が `play vars` より高いため、上記のような結果となります。

では更に優先順位の高い `extra_vars` (コマンドラインから指定する変数) を使うとどうなるか見てみましょう。

`vars_task_playbook.yml` に `-e` オプションをつけて実行します。

`ansible-playbook vars_task_playbook.yml -e 'task_vars=50'`{{execute}}

```bash
(省略)
TASK [print task_vars 1] ************
ok: [node-1] => {
    "task_vars": "50"
}

TASK [override task_vars] ***********
ok: [node-1] => {
    "task_vars": "50"
}

TASK [print task_vars 2] ************
ok: [node-1] => {
    "task_vars": "50"
}
```

## その他の変数定義
---
その他の変数の定義方法について紹介します。


### set_fact での定義
---
[set_fact](https://docs.ansible.com/ansible/latest/modules/set_fact_module.html) モジュールを使って、タスクパートの中で任意の変数を定義することができます。一般的な用途として、1つのタスクの実行結果を受け取り、その値を加工して新たな変数を定義し、その値を後続のタスクで利用する場合があります。

`set_fact` を使う演習は次のパートで登場します。


### host\_vars, group\_vars での定義
---
インベントリーの項目でも解説した変数です。特定のグループやホストに関連付けられるます。インベントリーファイルに記載する以外にも、実行する playbook と同一ディレクトリに、`gourp_vars` `host_vars` ディレクトリを作成して、そこに `group_name.yml ``node_name.yml` ファイルを作成することでグループ、ホスト変数として認識させることができます。

>Note: この `gourp_vars` `host_vars` というディレクトリ名は Ansible 内で決め打ちされた名前で変えることはできません。

`working/group_vars/all.yml` を編集してグループ変数を定義します。
```yaml
---
vars_by_group_vars: 1000
```

`working/host_vars/node-1.yml` を編集してホスト変数を定義します。
```yaml
---
vars_by_host_vars: 111
```

`working/host_vars/node-2.yml` を編集してホスト変数を定義します。
```yaml
---
vars_by_host_vars: 222
```

`working/host_vars/node-3.yml` を編集してホスト変数を定義します。
```yaml
---
vars_by_host_vars: 333
```

`working/vars_host_group_playbook.yml` を編集してこれらの変数を利用する playbook を作成します。
```yaml
---
- hosts: all
  gather_facts: no
  tasks:
    - name: print group_vars
      debug:
        var: vars_by_group_vars

    - name: print host vars
      debug:
        var: vars_by_host_vars

    - name: vars_by_group_vars + vars_by_host_vars
      set_fact:
        cal_result: "{{ vars_by_group_vars + vars_by_host_vars }}"

    - name: print cal_vars
      debug:
        var: cal_result
```

`vars_host_group_playbook.yml` を実行します。

`ansible-playbook vars_host_group_playbook.yml`{{execute}}

```bash
(省略)
TASK [print group_vars] ******************************
ok: [node-1] => {
    "vars_by_group_vars": 1000
}
ok: [node-2] => {
    "vars_by_group_vars": 1000
}
ok: [node-3] => {
    "vars_by_group_vars": 1000
}

TASK [print host vars] *******************************
ok: [node-1] => {
    "vars_by_host_vars": 111
}
ok: [node-2] => {
    "vars_by_host_vars": 222
}
ok: [node-3] => {
    "vars_by_host_vars": 333
}

TASK [vars_by_group_vars + vars_by_host_vars] ********
ok: [node-1]
ok: [node-2]
ok: [node-3]

TASK [print cal_vars] ********************************
ok: [node-1] => {
    "cal_result": "1111"
}
ok: [node-2] => {
    "cal_result": "1222"
}
ok: [node-3] => {
    "cal_result": "1333"
}
(省略)
```


### register による実行結果の保存
---
Ansible のモジュールは実行されると様々な戻り値を返します。playbook の中ではこの戻り値をを保存して後続のタスクで利用することができます。。その際に利用するのが `register` 句です。`register` は変数名を指定すると、その変数に戻り値を格納します。

`working/vars_register_playbook.yml` を以下のように編集します。
```yaml
---
- hosts: node-1
  gather_facts: no
  tasks:
    - name: exec hostname command
      shell: hostname
      register: ret

    - name: print ret
      debug:
        var: ret

    - name: create a directory
      file:
        path: /tmp/testdir
        state: directory
        mode: '0755'
      register: ret

    - name: print ret
      debug:
        var: ret
```


`vars_register_playbook.yml` を実行します。

`ansible-playbook vars_register_playbook.yml`{{execute}}

```bash
(省略)
TASK [exec hostname command] *************************
changed: [node-1]

TASK [print ret] *************************************
ok: [node-1] => {
    "ret": {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python"
        },
        "changed": true,
        "cmd": "hostname",
        "delta": "0:00:00.005958",
        "end": "2019-11-17 14:02:44.892010",
        "failed": false,
        "rc": 0,
        "start": "2019-11-17 14:02:44.886052",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "ip-10-0-0-92.ap-northeast-1.compute.internal",
        "stdout_lines": [
            "ip-10-0-0-92.ap-northeast-1.compute.internal"
        ]
    }
}

TASK [create a directory] ****************************
changed: [node-1]

TASK [print ret] *************************************
ok: [node-1] => {
    "ret": {
        "changed": true,
        "diff": {
            "after": {
                "mode": "0755",
                "path": "/tmp/testdir",
                "state": "directory"
            },
            "before": {
                "mode": "0775",
                "path": "/tmp/testdir",
                "state": "absent"
            }
        },
        "failed": false,
        "gid": 1000,
        "group": "centos",
        "mode": "0755",
        "owner": "centos",
        "path": "/tmp/testdir",
        "secontext": "unconfined_u:object_r:user_tmp_t:s0",
        "size": 6,
        "state": "directory",
        "uid": 1000
    }
}
```

## 演習の解答
---
- [vars_debug_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/solutions/vars_debug_playbook.yml)
- [vars_play_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/solutions/vars_play_playbook.yml)
- [vars_task_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/solutions/vars_task_playbook.yml)
- [vars_host_group_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/solutions/vars_host_group_playbook.yml)
  - [host_vars/node-1.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/solutions/host_vars/node-1.yml)
  - [host_vars/node-2.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/solutions/host_vars/node-2.yml)
  - [host_vars/node-3.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/solutions/host_vars/node-3.yml)
  - [group_vars/all.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/solutions/group_vars/all.yml)
- [vars_register_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/solutions/vars_register_playbook.yml)

