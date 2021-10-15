# 演習の概要と環境の準備
---
ここでは演習環境の概要の解説と、演習環境の準備を行います。

## 演習環境について
---
本演習はAWS上に構築されたで行われます。演習環境は以下のように構成されています。

![environment.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/kata_env.png)


## 演習環境の利用方法
---
講師の案内に従い演習環境へアクセスしてください。

### ターミナルの起動
---
JupyterLab上でターミナルを起動します。画面左側の「フォルダ」アイコンをクリックして、ファイルブラウザーを起動します。すでに起動している場合はそのままにしてください。

![open_file_browser](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/open_file_browser.png)

ファイルブラウザーの「+」ボタンをクリックしランチャーを起動します。

![add_launcher](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/add_launcher.png)

ランチャー内の「Other」から「Terminal」アイコンをクリックします。

![open_terminal](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/open_terminal.png)

ターミナルを起動したら動作確認を行います。以下のコマンドをターミナルから実行してください。

> Note: 本演習では、 `{{execute}}` とついている部分が、演習で実行するコマンドになります。 `{{execute}}` 自身は入力する必要はありません。

`ansible --version`{{execute}}

```text
ansible [core 2.11.5] 
  config file = /jupyter/.ansible.cfg
  configured module search path = ['/jupyter/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.8/site-packages/ansible
  ansible collection location = /jupyter/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.8.6 (default, Jan 29 2021, 17:38:16) [GCC 8.4.1 20200928 (Red Hat 8.4.1-1)]
  jinja version = 3.0.2
  libyaml = True
```

`ansible all -m ping -o`{{execute}}

```text
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/libexec/platform-python"},"changed": false,"ping": "pong"}
node-2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/libexec/platform-python"},"changed": false,"ping": "pong"}
node-3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/libexec/platform-python"},"changed": false,"ping": "pong"}
```

> Note: 表示されるバージョン等の差異については無視してください。コマンドがエラーにならなければ演習が可能な状態になっています。


起動したターミナルはタブをドラッグして移動することて表示位置を変更できます。以下の例のように、Markdown と並べて表示することもできますので、演習が進めやすいように各自配置を変更してください。

![vertical_split_terminal](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/vertical_split_terminal.png)


### 補足事項
---
本演習環境でファイルを編集する場合には左側のファイルブラウザからファイルを開くことでエディタを起動できます（ターミナル内で vi を使うことも可能です）。

一部のファイル形式(.md や .html) はファイルブラウザからダブルクリックで開くとプレビュー表示となります。ファイルを編集したい場合は「右クリック」 → 「Open with」 から Editor を選択してください。

