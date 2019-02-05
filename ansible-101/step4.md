簡単な Playbook を作成して自動化を動かしてみます。

## 説明

![image2-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/ansible-101/images/image2-1.png "image2-1")

Ansible ではモジュールを Playbook へと記述することで「やりたいこと」を表現します。図では、`role` という中間の形態を踏んでいますが、一旦ここは無視してください。

ここでは、シンプルにモジュールを使って Playbook を記述していきます。

## 演習

Playbook はYAML形式で記述されるテキストファイルですが、大きく2つのパートを持ちます。

- `Play`パート ・・・Playbook 全体の挙動に関する指定や、インベントリのグループを指定しています。Playbook のヘッダーとも言える箇所です。
- `Task`パート ・・・モジュールを使って実際にやりたいことを記述します。Plyabook の中心となる箇所です。


### ステップ 1

Play パートを定義します。ファイル `install_apache.yml` を作成して編集していきます。

`vim install_apache.yml`{{execute}}

以下の例のように記述してください。

```
---
- hosts: web
  name: Install the apache web service
  become: yes
```

- `---` はYAMLの開始を意味しています。
- `hosts: web` はplayを走らせる対象のホスト・グループをInventoryの中で定義しています。
- `name: Install the apache web service` この Playbook についての説明です。
- `become: yes` ユーザ権限のエスカレーションを要求します。デフォルトでは sudo ですが、suや pbrun 、またその他ものもサポートされています。一般的に、root などの特定ユーザーでしか実行できないタスクのために必要となります。


### ステップ 2

Play パートの後に Task パートを追加します。

tasks の t と、become の b はインデントの位置を合わせ、垂直に揃えてください。

この記述の仕方がとても重要です。Playbook内の記述は、すべてここで示されているサンプルと同一である必要があります（YAML形式はインデント＝段差げが意味を持つ記法です。段差げの位置が例と異なると、Playbookはうまく動作しません）

```
  tasks:
    - name: install apache
      yum:
        name: httpd
        state: present
    
    - name: start httpd
      service:
        name: httpd
        state: started
```

- `tasks:` これでこの後1つ以上のtaskが定義されることを示しています。
- `- name:` 各taskには名前をつける必要があります。この名前はPlaybookを走らせた際に、標準出力に表示されます。分かりやすいよう、短く明快な名前をつけてください。

ここでは2つのモジュールが Task パートで呼び出されています。それぞれを見ていきましょう。

```
  yum:
    name: httpd
    state: present
```

Ansibleのyumモジュールによるhttpdのインストールは3行で記述されています。yumモジュールの全てのオプションは[ここをクリック](https://docs.ansible.com/ansible/latest/modules/yum_module.html)して確認してください。

```
  service:
    name: httpd
    state: started
```

その後に続く数行は、httpdサービスを起動するAnsibleのserviceモジュールです。serviceモジュールはリモート・ホストのサービスの制御に利用します。[ここをクリック](https://docs.ansible.com/ansible/latest/modules/service_module.html)して、serviceモジュールの詳細を確認してください。

### ステップ3

Playbook の全体像を確認します。

Playbookを書き上げることができたたらファイルを保存してエディタを終了してください。

以下のコマンドで Playbook の内容を確認してみましょう。

`cat install_apache.yml`{{execute}}

出力例が以下と相違ないことを確認してください。

```
---
- hosts: web
  name: Install the apache web service
  become: yes
  tasks:
    - name: install apache
      yum:
        name: httpd
        state: present
   
    - name: start httpd
      service:
        name: httpd
        state: started
```

Ansible（実際にはYAMLですが）は適切にフォーマットされている必要があり、特にインデント／スペーシングは厳格さが求められます。転ばぬ先の杖ではありませんが、時間ができたならこの [YAML Syntax](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html) に目を通しておきましょう。

それはさておき、以上がここまでで書き終えたPlaybookの全体像です。スペースと行頭の揃えに注意して見てください。


### ステップ 4

人の目だけで構文の誤りを検出することはなかなか大変だったのではないでしょうか。これはPlaybookの規模が大きくなると加速度的に難しくなります。

しかし安心してください。Ansible には Playbook のシンタックスチェックを行う機能を持っています。この機能を使って Playbook をチェックしてみましょう。

`ansible-playbook -i ./my_inventory install_apache.yml --syntax-check`{{execute}}

- `-i` このオプションは、利用する特定のInventoryファイルを指定します。
- `--syntax-check` 意図したとおりにPlaybookが走らない場合は、このオプションを使えばどこで問題が発生しているのか調べることができます。コードのコピー／ペーストで発生したによる問題箇所も見つけることができるはずです。

もし、このコマンドがエラーを返す場合は、一つ前の手順に戻り、Playbook の内容を再度確認してください。


### ステップ 5

では Playbook を実行してみましょう。

`ansible-playbook -i ./my_inventory -u root -k install_apache.yml`{{execute}}

- `-k` このオプションは、ユーザがPlaybookを走らせる際にパスワードを要求します。
- `-v` ここでは使用していませんが、このオプションを使えば冗長出力モードでPlaybookを走らせることができます。2回目にPlaybookを走らせる際、-vまたは-vvを利用して表示されるメッセージを増やしてみてください。

コマンドが終了したら、ターミナル上部の`node-1`, `node-2` ... をクリックして、本当に設定が行われたのかを確認してください。

無事、Apache の初期画面が確認できれば成功です！


### ステップ 6

無事 Playbook が実行できたら、以下の先程と同じコマンドをもう一度実行してみましょう。

`ansible-playbook -i ./my_inventory -u root -k install_apache.yml`{{execute}}

この出力結果が先程とどのような違いがあるのか確認してください。

各タスクが以下の出力であったはずです。

- 1回目は `changed`
- 2回目は `ok`

この違いは Ansible が備える「冪等性」によってもたらされています。

Ansible のモジュールは実際に変更を行う前に、「今から行う処理を実行する必要があるのか、ないのか」を判定します。例えば `yum` モジュールでパッケージをインストールする場合は、指定したパッケージがインストールされているのか、されていないのかを調べます。そして、インストールされていなければパッケージのインストールが行われ(`changed`)、既にインストールされていれば処理をスキップ(`ok`)としてくれます。

この機能は自動化を実用する上でとても有益です。この特性をうまく使うことで、設定管理を簡素化することが可能です。


### ステップ 7

今度は、ここまででやってきたのと反対のことを行ってみます。Apacheを停止させ、Webノードからアンインストールします。まずそのためにPlaybookを編集して、それが終ったらステップ 5のやり方で走らせます。この演習ではこれまでのように逐一の説明は行いませんが、いくつかのヒントを用意しました。

- 先のPlaybookの最初のtaskがhttpdのインストールで、2つ目のtaskがその起動であったことを考えれば、今回はそれらのtaskをどのような順番にすればよいでしょうか？
- startedでhttpdサービスが起動したのであれば、それを停止させるためのオプションはなんでしょうか？
- presentオプションでパッケージがインストールされていることを確認するのであれば、アンインストールを確認するオプションは何でしょうか？最初はabの2文字ではじまり、sentで終る単語です。
- [yum モジュールの解説](https://docs.ansible.com/ansible/latest/modules/yum_module.html)
- [service モジュールの解説](https://docs.ansible.com/ansible/latest/modules/service_module.html)


本演習は以上となります。

[Back to top page](https://www.katacoda.com/irixjp)
