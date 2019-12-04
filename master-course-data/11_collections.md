# Collections
---
`Collection` は Galaxy の再利用の仕組みを更に一歩進めたものです。複数のロールやカスタムモジュールをまとめて管理し配布することが可能です。Ansible 2.9 以降(2.8から実験的には利用可能)で利用できます。

従来は1ロール1リポジトリで管理していたものを、組織やチームで利用する共通機能をまとめて1リポジトリで管理できるようになります。

## Collection の利用
---
演習では既に作成済みのサンプルコレクション [https://galaxy.ansible.com/irixjp/sample_collection_hello](https://galaxy.ansible.com/irixjp/sample_collection_hello) を利用します。このコレクション名は `irixjp.sample_collection_hello` です。オリジナルのソースコードは [github](https://github.com/irixjp/ansible-sample-collection-hello) に格納されています。

> Note: コレクション名は `<namespace>.<collection_name>` という形式で表現されます。

このコレクションは以下を含んでいます。

- role: hello
- role: uptime
- module: sample\_get\_hello

コレクションを利用するには、`requirements.yml` を作成します。

`~/working/collections/requirements.yml` を以下のように編集します。

```yaml
---
collections:
- irixjp.sample_collection_hello
```

コレクションを取得するには以下を実行します。標準で`~/.ansible/collections/` へコレクションがダウンロードされます。`-p` をつけると保存先を変更でき、`-f` で強制的に最新版に上書きを行います。

`ansible-galaxy collection install -r collections/requirements.yml`{{execute}}

取得したコレクションを利用する playbook を作成します。コレクションへのアクセスは以下の形式で行います。

`<namespace>.<collection_name>.<role or module name>`

`~/working/collection_playbook.yml` を以下のように編集します。

```yaml
---
- name: using collection
  hosts: node-1
  tasks:
    - import_role:
        name: irixjp.sample_collection_hello.hello

    - import_role:
        name: irixjp.sample_collection_hello.uptime

    - name: get locale
      irixjp.sample_collection_hello.sample_get_locale:
      register: ret

    - debug: var=ret
```

実行結果を確認します。

`ansible-playbook collection_playbook.yml`{{execute}}

```bash
TASK [hello : say hello! (C)] **************
ok: [node-1] => {
    "msg": "Hello"
}

TASK [uptime : get uptime] *****************
ok: [node-1]

TASK [uptime : debug] **********************
ok: [node-1] => {
    "msg": " 03:38:16 up 4 days, 23:01,  1 user,  load average: 0.16, 0.05, 0.06"
}

TASK [get locale] **************************
ok: [node-1]

TASK [debug] *******************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "failed": false,
        "locale": "C.UTF-8"
    }
}
```

コレクション内の各ロール、モジュールを呼出していることが確認できます。単体のロールのときと違い、カスタムモジュールを単体で呼び出すことも可能で、更に利便性が向上しています。

## 補足情報
---
必要に応じて以下も確認してください。

- より詳細な利用方法: [Using collections](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)
- コレクションを作成する方法: [Developing collections](https://docs.ansible.com/ansible/devel/dev_guide/developing_collections.html)

コマンドラインでは `ansible-galaxy collection install` をつど実行する必要がありますが、Ansible Tower/AWX では playbook の実行前に自動的に `requirements.yml` からロールをダウンロードする機能がありますので、更新し忘れといった事故を防ぐことが可能です。


## 演習の解答
---
- [collection_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/collection_playbook.yml)
- [requirements.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/collections/requirements.yml)
