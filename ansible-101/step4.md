Playbook を作成します。

## 説明

![image2-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/ansible-101/images/image2-1.png "image2-1")

Ansible ではモジュールを Playbook へと記述することで「やりたいこと」を表現します。図では、`role` という中間の形態を踏んでいますが、一旦ここは無視してください。

ここでは、シンプルにモジュールを使って Playbook を記述してみます。

## 演習

Playbook はYAML形式で記述されるテキストファイルですが、大きく2つの内容を持ちます。

- `Play`パート ・・・Playbook 全体の挙動に関する指定や、インベントリのグループを指定しています。
- `Task`パート ・・・モジュールを使って実際にやりたいことを記述します。

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

- --- はYAMLの開始を意味しています。
- hosts: web はplayを走らせる対象のホスト・グループをInventoryの中で定義しています。
- name: Install the apache web service playについての説明です。
- become: yes ユーザ権限のエスカレーションを可能にします。デフォルトではsudoですが、suやpbrun、またその他ものもサポートされています。


### ステップ 2

Play パートの後に Task パートを追加します。

tasks の t と、become の b はインデントの位置を合わせ、垂直に揃えてください。
この記述の仕方がとても重要です。Playbook内の記述は、すべてここで示されている形式に倣う必要があります。
（YAML形式はインデント＝段差げが意味を持つ記法です。段差げの位置が例と異なると、Playbookはうまく動作しません）

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

- tasks: これでこの後1つ以上のtaskが定義されることを示しています。
- - name: 各taskには名前をつける必要があります。この名前はPlaybookを走らせた際、標準出力に表示されます。分かりやすいよう、短く明快名前をつけてください。

ここでは2つのモジュールが Taskパートで呼び出されています。

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

さて、ここまででPlaybookを書き上げることができたので保存してエディタを終了してください。

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

Ansible（実際にはYAMLですが）は適切にフォーマットされている必要があり、特にインデント／スペーシングは厳格さが求められます。転ばぬ先の杖ではありませんが、時間ができたならこのYAML Syntaxに少し目を通しておきましょう。それはさておき、以下がここまでで書き終えたPlaybookの全体像です。スペーシングと行頭の揃えに注意して見てください。

### ステップ 4

Playbook のシンタックスチェックを実行してみましょう。

`ansible-playbook -i ./my_inventory -u root -k install_apache.yml --syntax-check`{{execute}}

- -i このオプションは、利用する特定のInventoryファイルを指定します。
- -k このオプションは、ユーザがPlaybookを走らせる際にパスワードを要求します。
- -v ここでは使用していませんが、このオプションを使えばバーボス・モードでPlaybookを走らせることができます。2回目にPlaybookを走らせる際、-vまたは-vvを利用して表示されるメッセージを増やしてみてください。
- --syntax-check 意図したとおりにPlaybookが走らない場合は、このオプションを使えばどこで問題が発生しているのか調べることができます。コードのコピー／ペーストで発生したによる問題箇所も見つけることができるはずです。

もし、このコマンドがエラーを返す場合は、一つ前の手順に戻り、Playbook の内容を再度確認してください。


### ステップ 5

最後に Playbook を実行してみましょう。

`ansible-playbook -i ./my_inventory -u root -k install_apache.yml`{{execute}}

コマンドが終了したら、ターミナル上部の`node-1`, `node-2` ... をクリックして、本当に設定が行われたのかを確認してください。

無事、Apache の初期画面が確認できれば成功です！


### ステップ 6

今度は、ここまででやってきたのと反対のことを行ってみます。Apacheを停止させ、Webノードからアンインストールします。まずそのためにPlaybookを編集して、それが終ったらステップ 5のやり方で走らせます。この演習ではこれまでのように逐一の説明は行いませんが、いくつかのヒントを用意しました。

- 先のPlaybookの最初のtaskがhttpdのインストールで、2つ目のtaskがその起動であったことを考えれば、今回はそれらのtaskをどのような順番にすればよいでしょうか？
- startedでhttpdサービスが起動したのであれば、それを停止させるためのオプションはなんでしょうか？
- presentオプションでパッケージがインストールされていることを確認するのであれば、アンインストールを確認するオプションは何でしょうか？最初はabの2文字ではじまり、sentで終る単語です。
- [yum モジュールの解説](https://docs.ansible.com/ansible/latest/modules/yum_module.html)
- [service モジュールの解説](https://docs.ansible.com/ansible/latest/modules/service_module.html)

