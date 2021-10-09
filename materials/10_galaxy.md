# Role の管理と再利用
---
ここでは作成したロールの管理と再利用方法についてみていきます。ロールによって playbook の部品化が可能となりますが、その部品を再利用する時に、毎回 `roles` ディレクトリにロール一式をコピーする方法は好ましく有りません。コピーした後に元ロールが変更された場合に、その変更に追随できないためです。またこのようなソースコードの分散を管理しようとしたときの手間も膨大となります。

この問題を解決するために、Ansible では playbook 実行に必要となるロール一式をまとめて取得する方法があります。それが [ansible-galaxy](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html) です。

Galaxy の利用とあわせて、Role 管理の手法について解説していきます。

## Role の管理方法
---
Ansible ではロールの管理に `git` 等のソースコード管理システムの利用を強く推奨しています。

> Note: 推奨という表現をしていますが、実質的にほぼ必須です。もちろん手動で Role や playbook のファイルを管理することも可能です。しかし、あくまで可能というだけで、どのような事情があれ「手動管理はすべきでありません」と強く明記しておきます。

ロールを git で管理する場合には、「1ロール=1リポジトリ」が基本となります。この管理手法を採用すると、リポジトリが大量にできることになるため、あわせてロールのカタログを作成すると見通しがよくなります。Ansible が公式で提供しているカタログの仕組みとして [Galaxy](https://galaxy.ansible.com/) というサイトがあり、ここに自分のロールを登録することも可能です。

Galaxy には既に膨大な数のロールが登録されており、大抵の場合は検索すると自分のやりたいことを見つけることができます。

> Note: そのまま使えるケースもあれば、改造が必要なケースもあります。しかし、毎回ゼロか調べながらロールを作成するという手間を大幅に削減できます。

## `ansible-galaxy` コマンドの利用
---
演習用のロールをインポートして活用してみます。既に作成され、git 上でアクセス可能になっているロールを再利用するためには `ansible-galaxy` コマンドを利用します。

今回利用するロールは以下です。

- [irixjp.role\_example\_hello](https://galaxy.ansible.com/irixjp/role_example_hello) あいさつを表示するだけのロール
- [irixjp.role\_example\_uptime](https://galaxy.ansible.com/irixjp/role_example_uptime) uptimeの結果を表示するだけのロール

> Note: `Galaxy` 用のロールを作成するには通常のロールに [`meta`](https://galaxy.ansible.com/docs/contributing/creating_role.html) データを付加し、Galaxy に登録するだけです。

これらのロールをまとめて取得するには `requirements.yml` ファイルを準備します。

`~/working/roles/requirements.yml` を以下のように編集してください。

```yaml
---
- src: irixjp.role_example_hello
- src: irixjp.role_example_uptime
```

`requirements.yml` の書式は [こちら](https://galaxy.ansible.com/docs/using/installing.html) で詳細が解説されています。ここでは Galaxy 上でのカタログ名(`irixjp.role_example_hello`)を指定していますが、github や自社 git サーバーを直接参照させることも可能です。

次にこのロールを利用する `~/working/galaxy_playbook.yml` を作成します。
```yaml
---
- name: using galaxy
  hosts: node-1
  tasks:
    - import_role:
        name: irixjp.role_example_hello

    - import_role:
        name: irixjp.role_example_uptime
```

これで準備が整いました。

## Role のダウンロードと playbook の実行
---
Galaxy からロールを習得します。

`cd ~/working`{{execute}}

`ansible-galaxy role install -r roles/requirements.yml`{{execute}}

```text
- downloading role 'role_example_hello', owned by irixjp
- downloading role from https://github.com/irixjp/ansible-role-sample-hello/archive/master.tar.gz
- extracting irixjp.role_example_hello to /jupyter/.ansible/roles/irixjp.role_example_hello
- irixjp.role_example_hello (master) was installed successfully
- downloading role 'role_example_uptime', owned by irixjp
- downloading role from https://github.com/irixjp/ansible-role-sample-uptime/archive/master.tar.gz
- extracting irixjp.role_example_uptime to /jupyter/.ansible/roles/irixjp.role_example_uptime
- irixjp.role_example_uptime (master) was installed successfully
```

`ansible-galaxy install` コマンドは標準でロールを `$HOME/.ansible/roles` へ展開します。これは `-p` オプションで制御することが可能です。

また `-f` を使うことで既存でダウンロードされたロールを上書きして習得しますので、常に最新のロールを利用することが可能になります。

ダウンロードされたロールを確認するは以下のコマンドを実行します。

`ansible-galaxy role list`{{execute}}

```text
# /root/.ansible/roles
- irixjp.role_example_uptime, master
- irixjp.role_example_hello, master
```

実際に playbook を実行します。

`ansible-playbook galaxy_playbook.yml`{{execute}}

```text
TASK [irixjp.role_example_hello : say hello!] ********
ok: [node-1] => {
    "msg": "Hello"
}

TASK [irixjp.role_example_uptime : get uptime] *******
changed: [node-1]

TASK [irixjp.role_example_uptime : debug] ************
ok: [node-1] => {
    "msg": " 07:41:00 up 1 day,  3:04,  1 user,  load average: 0.00, 0.01, 0.05"
}
```

このようにロールを git 上で管理し、必要なロールを `requirements.yml` で管理することで、ソースコードの分散を抑え、効率と安全性を高めることが可能になります。

## Role 内のカスタムモジュールやカスタムフィルターの利用
---
Role に含まれるカスタムモジュールやカスタムフィルターは、そのロールが playbook に読み込まれると、ロール外のタスクでも使用可能になります。

例としてロール `irixjp.role_example_hello` はカスタムモジュール `sample_get_locale` を含んでいます。

このカスタムモジュールは以下のように使用できます。 `~/working/galaxy_playbook.yml` を編集します。
```yaml
---
- name: using galaxy
  hosts: node-1
  tasks:
    - import_role:
        name: irixjp.role_example_hello

    - import_role:
        name: irixjp.role_example_uptime

    - name: get locale
      sample_get_locale:
      register: ret

    - debug: var=ret
```

実行します。

`ansible-playbook galaxy_playbook.yml`{{execute}}

```text
(省略)
TASK [get locale] *********************
ok: [node-1]

TASK [debug] **************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "failed": false,
        "locale": "en_US.UTF-8"
    }
}
```

ロールの後続でカスタムモジュールが実行できていることが確認できます。

このように、ロールはカスタムモジュールの配布の仕組みとして利用することができます。この場合は、ロールの `tasks/main.yml` を空にしておいて、ロール自身はタスクを何も実行しないという形で実装します。


## Galaxy 用ロールの作成方法
---
Galaxy を利用して再配布可能なロールを作成するためにはリポジトリに `galaxy.yml` を含める必要があります。作成方法は [Creating Roles](https://galaxy.ansible.com/docs/contributing/creating_role.html) を参照してください。


## 補足の情報
---
コマンドラインでは `ansible-galaxy role install` をつど実行する必要がありますが、Ansible Automation Platform や /AWX では playbook の実行前に自動的に `requirements.yml` からロールをダウンロードする機能がありますので、更新し忘れといった事故をシステム的に防止することが可能です。


## 演習の解答
---
- [galaxy\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/galaxy_playbook.yml)
- [requirements.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/roles/requirements.yml)
