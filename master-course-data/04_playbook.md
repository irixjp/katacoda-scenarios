# Playbookの記述と実行
---
先の演習ではモジュールを1つずつ実行しましたが、実際に作業を行う場合はいくつのも手順を連続して実行することになります。このときに使用するのが `playbook` です。playbook には呼出したいモジュールとパラメーターを順番に記述し、一連の手順として連続して実行することができます。

## Playbook の基礎
---
`playbook` は [YAML](https://ja.wikipedia.org/wiki/YAML) 形式で記述します。YAMLに関して重要なポイントを以下に記載します。

- YAML はデータを表記するためのテキストフォーマットであること。
- ファイルの先頭は `---` から始まる
- インデントが意味を持つ
  - インデントは `space` で表記する。`tab` ではエラーとなります。
- `-` はリストを表す
- `key`: `value` で辞書形式となる
- [json](https://ja.wikipedia.org/wiki/JavaScript_Object_Notation) と相互に変換可能

以下は playbook のサンプルです。
```yaml
---
- hosts: all
  become: yes
  tasks:
  - name: first task
    yum:
      name: httpd
      state: latest
  - name: second task
    service:
      name: httpd
      state: started
      enabled: yes
```

この内容は、json で表記すると以下のようになります。

```json
[
	{
		"hosts": "all",
		"become": "yes",
		"tasks": [
			{
				"name": "first task",
				"yum": {
					"name": "httpd",
					"state": "latest"
				}
			},
			{
				"name": "second task",
				"service": {
					"name": "httpd",
					"state": "started",
					"enabled": "yes"
				}
			}
		]
	}
]
```

## playbook の作成
---
では実際に playbook を作成します。

`~/working/first_playbook.yml` をエディタで開いてください。このファイルには先頭に `---` のみが記載されています。以下の説明に従いこのファイルへ追記を行い、playbook として完成させます。

ここでは、WEBサーバーを構築する playbook を作成します。

### play パート
---
以下のようにファイルに追記してください。

```yaml
---
- name: deploy httpd server
  hosts: all
  become: yes
```

ここで記述した内容な以下になります。
- `name:`: ここには、この playbook で行う処理の概要を記載します。省略可能。日本語を使うことも可能です。
- `hosts: all`: playbook の実行対象となるグループやノードを指定します。
- `become: yes`: この playbook では権限昇格を行うことを宣言しています。コマンドラインで与える `-b` と同じ意味です。

この部分は、playbook 内の `play` パートと呼ばれる部分で全体に関する挙動を宣言します。playパートで指定できる項目の[詳細については公式ドキュメント](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html#play) を確認してください。

### task パート
---
次に以下を追記します。インデントの階層に注意してください。

```yaml
---
- name: deploy httpd server
  hosts: all
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
```

ここで追記した内容は `task` パートと呼ばれる部分になり、実際にこの playbook が行う処理を記述していきます。task パートではモジュールを呼び出す順番に列挙し、必要なパラメーターを与えます。

- `tasks:` これ以降が task パートであることを宣言しています。
- `- name: ...` このタスクの説明を記載しています。省略可能
- `yum:` `service:` 呼び出すモジュールを指定しています。
- 以下はモジュールに与えられているパラメーターです。
  - `name: httpd` `state: latest`
  - `name: httpd` `state: started` `enabled: yes`

ここで呼び出しているモジュールは以下になります。
- [`yum`](https://docs.ansible.com/ansible/latest/modules/yum_module.html): httpd パッケージをインストールするために利用します。
- [`service`](https://docs.ansible.com/ansible/latest/modules/service_module.html): インストールされた httpd を起動し、自動起動の設定を有効にしています。

作成した playbook に構文エラーがないかを以下のコマンドで確認できます。

`cd ~/working`{{execute}}

`ansible-playbook first_playbook.yml --syntax-check`{{execute}}

```bash
playbook: first_playbook.yml
```

上記はエラー無しのケースです。もしインデントなどに誤りがある場合は以下のようになります。
```bash
$ ansible-playbook first_playbook.yml --syntax-check

ERROR! Syntax Error while loading YAML.
  expected <block end>, but found '<block sequence start>'

The error appears to be in '/notebooks/working/first_playbook.yml': line 6, column 2, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:

  tasks:
 - name: install httpd
 ^ here
```

この場合には、playbook のインデントなどがサンプルと同じになっているかを再度確認してください。

## playbook の実行
---
作成した playbook を実行します。playbook の実行には `ansible-playbook` コマンドを利用します。成功すれば httpd サーバーが起動して apache の初期画面が参照できるはずです。

`ansible-playbook first_playbook.yml`{{execute}}

```bash
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node-2]
ok: [node-3]
ok: [node-1]

TASK [install httpd] ********************************************************
changed: [node-1]
changed: [node-2]
changed: [node-3]

TASK [start & enabled httpd] ************************************************
changed: [node-1]
changed: [node-2]
changed: [node-3]

PLAY RECAP ******************************************************************
node-1  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

上記のような出力となれば成功です。node-1,2,3 に対してブラウザでアクセスしてサイトの動作を確認してください。

> Note: katacoda 上で演習をしている場合は、画面上部の `node-1,2,3` をクリックします。

> Note: Jupyter 上で演習をしている場合は、アクセスするIPアドレスを `~/inventory` で確認し、ブラウザでアクセスしてください。

以下のような画面が表示されれば成功です。

![apache_top_page.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/apache_top_page.png)


## タスクの追加
---
作成した plyabook にサイトのトップページを配布するタスクを追加します。

`~/working/files/index.html` をエディタで開きます。

ファイルを以下のように編集します。
```html
<body>
<h1>Apache is running fine</h1>
</body>
```

さらに `first_playbook.yml` を以下のように編集します。
```yaml
---
- name: deploy httpd server
  hosts: all
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

  - name: copy index.html
    copy:
      src: files/index.html
      dest: /var/www/html/
```

編集が完了したら、構文チェックを実施した後に playbook を実行してみましょう。


`ansible-playbook first_playbook.yml --syntax-check`{{execute}}

`ansible-playbook first_playbook.yml`{{execute}}

```bash
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node-2]
ok: [node-3]
ok: [node-1]

TASK [install httpd] ********************************************************
ok: [node-1]
ok: [node-3]
ok: [node-2]

TASK [start & enabled httpd] ************************************************
ok: [node-2]
ok: [node-1]
ok: [node-3]

TASK [copy index.html] ******************************************************
changed: [node-1]
changed: [node-3]
changed: [node-2]

PLAY RECAP ******************************************************************
node-1  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

正常終了したら再びブラウザで3台のノードへアクセスしてください。正しく playbook が記述され、動作したのならば先程作成した `index.html` の内容が表示されるはずです。

## 冪等性(べきとうせい)
---
Ansible のモジュールを利用するメリットして、記述量を大幅に減らせるという解説を行いましたが、その他にもメリットがあります。それが `冪等性` です。

この演習では `ansible-playbook first_playbook.yml` を2回実行しています。httpd のインストールと起動を行った時、そしてサイトのトップページを追加したときです。つまり、httpd のインストールと起動のタスクは2回実行されています。しかし、2回目の playbook 実行にもエラー等は起きていません。これは Ansible の `冪等性` が機能しているからです。

1回目の実行結果と2回目の実行結果を注意深く確認すると、出力結果に違いがあることに気づくはずです。異なる箇所は、それぞれの処理において `changed` と出力されたか、`ok`と出力されたかです。

- `changed`: Ansibleが処理を実行した結果、対象ホストの状態が変わった（Ansibleが実際に設定を行った）
- `ok`: Ansibleは処理を行おうとしたが、既に想定した設定になっているので状態が変わらなかった（Ansibleは設定を行わなかった・行う必要がなかった）

この動作が Ansible が備える冪等性になります。Ansible は今から行おうとする処理を実行する必要があるのか、無いのかを実行前に判断してくれています。

ここで再度この playbook を実行してみましょう。3つのタスクの状態がどのようになるか考えてから実行してください。

`ansible-playbook first_playbook.yml`{{execute}}

```bash
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node-3]
ok: [node-1]
ok: [node-2]

TASK [install httpd] ********************************************************
ok: [node-2]
ok: [node-1]
ok: [node-3]

TASK [start & enabled httpd] ************************************************
ok: [node-1]
ok: [node-2]
ok: [node-3]

TASK [copy index.html] ******************************************************
ok: [node-3]
ok: [node-1]
ok: [node-2]

PLAY RECAP ******************************************************************
node-1  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

全てのタスクは `ok` となったはずです。playbook 実行時の最後の `PLAY RECAP` 部分を並べてみると結果の差が分かりやすく確認できます。ここでは各ノードにおいて、何個のタスクが `changed` になったのかを確認できます。


1回目(タスク2個がchanged)
```
PLAY RECAP ******************************************************************
node-1  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

2回目(タスク1個がchanged)
```
PLAY RECAP ******************************************************************
node-1  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

3回目(changedは0)
```
PLAY RECAP ******************************************************************
node-1  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

では、この冪等性は何が嬉しいのかというと、

- Playbookには「処理の手順ではなく、状態を宣言的に記述できる」→ Playbook＝設定パラメータ＋手順書として扱えるようになる。
- 仮に複数台のホストに対して実行した処理が途中で失敗しても、最初から流し直せる（設定が成功した部分はスキップされるため）

Ansible の各モジュールはこの冪等性を考慮するように作られており、このモジュールを利用することで簡単に、そして安全に自動化を記述することができるようになっています。

これがスクリプトの場合、特に再実行においてはスクリプトを頭から流し直していいのか？ダメなのか？等の面倒な考慮点が生まれてしまうことは容易に想像できると思います。

> Note: ただし、Ansibleも全てのモジュールが完全な冪等性を保証しているわけではありません。モジュールの中には shell のように何が実行されるかわからないものや、操作対象（NW系機器やクラウド環境）によっては原理的に冪等性の確保が難しいものも存在しています。こういったモジュールを使う場合は利用者が注意を払う必要があります

## 演習の解答
- [first_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/first_playbook.yml)
