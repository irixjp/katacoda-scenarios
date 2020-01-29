# 演習の概要と環境の準備
---
ここでは演習環境の概要の解説と、演習環境の準備を行います。

## 演習環境について
---
本演習はAWS上で行われます。予め事務局より配布されたAWSアカウントの情報を手元に準備してください。

演習環境は以下のような環境となります。

![environment.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/kata_env.png)


## 演習環境の準備
---
それでは演習環境をAWS上に構築します。Ansibleを使ってAWSを操作して環境を構築します。Ansible の使い方のイメージを掴んでもらうことが目的ですので、まだどんな処理を実行しているのかというのはあまり気にせずに演習を進めてください。

### ターミナルの起動
---
JupyterLab上でターミナルを起動します。画面左側の「フォルダ」アイコンをクリックして、ファイルブラウザーを起動します。すでに起動している場合はそのままにしてください。

![open_file_browser](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/open_file_browser.png)

ファイルブラウザーの「+」ボタンをクリックしランチャーを起動します。

![add_launcher](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/add_launcher.png)

ランチャー内の「Other」から「Terminal」アイコンをクリックします。

![open_terminal](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/open_terminal.png)

起動したターミナルはタブをドラッグして移動することて表示位置を変更できます。以下の例のように、Markdown と並べて表示することもできますので、演習が進めやすいように各自配置を変更してください。

![vertical_split_terminal](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/vertical_split_terminal.png)

### AWS操作のためのセットアップ
---
ここでは、AWSをAnsibleから操作するために以下の情報を設定します。

| 項目                  | パラメーター         | 確認方法 |
|:---------------------|:-------------------|:-------|
|AWS Access Key ID     |自分のアクセスキー    |事務局から発行された値を使ってください |
|AWS Secret Access Key |自分のシークレットキー |事務局から発行された値を使ってください |
|Default region name   |ap-northeast-1     | |
|Default output format |json               | |

ターミナルから以下のコマンドを実行します。上記の値の入力を求められますので、各自「**自分に割り当てられた値**」を入力してください。以下のサンプル値を入力しても演習は行なえません。

`aws configure`{{execute}}

```bash
AWS Access Key ID [None]: AABBCCDDEEFFGG
AWS Secret Access Key [None]: AABBCCDDEEFFGGHHIIJJKKLLMMNN
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

動作確認のため、以下のコマンドを実行してください。このコマンドにエラーがでなければ正常に設定は完了しています。

`aws ec2 describe-instances`{{execute}}

```bash
{}
```

このコマンドは、起動しているインスタンスの一覧を出力するコマンドです。AWS上でインスタンスを起動している場合は、そのインスタンスの情報が出力されます。

> Note: 入力ミス等でエラーとなった場合には、再度 `aws configure` コマンドを実行することで再設定が行えます。

これで準備作業は完了です。

### 演習環境の作成
---
準備されている Ansible の自動化を利用して演習環境を作成します。この自動化は上記の手順で設定したAWSアカウントに対して以下の動作を行います。

- 演習用の VPC の作成
- VPC subnet の作成
- インターネットゲートウェイの設定
- ルーティングの設定
- キーペアの作成
- インスタンスを3台起動する
- 起動したインスタンスがログイン可能になるのを待機する

早速、上記の手順を実行します。以下のコマンドをターミナルから実行してください。

`cd ~/tools`{{execute}}

`ansible-playbook ec2_prepare.yml`{{execute}}

```bash
PLAY [Setup handson environment] **********************

TASK [Create a VPC] ***********************************
changed: [localhost]

〜省略〜

TASK [SSH port is up? Waiting 30 sec ...] *************
ok: [node-1]
ok: [node-2]
ok: [node-3]

TASK [ping] *******************************************
ok: [node-1]
ok: [node-2]
ok: [node-3]

PLAY RECAP ********************************************
localhost : ok=20 changed=10 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-1    : ok=2  changed=0  unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2    : ok=2  changed=0  unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3    : ok=2  changed=0  unreachable=0 failed=0 skipped=0 rescued=0 ignored=0 
```

上記の出力例のようにエラーなく終了すれば成功です。これで演習の準備が整います。

もしエラーとなった場合には講師に確認を行ってください。

## 補足事項
---
本演習環境でファイルを編集する場合には左側のファイルブラウザからファイルを開くことでエディタを起動できます（ターミナル内で vi を使うことも可能です）。


## 講師用
---
演習用のJupyter環境は以下の手順で構築します。受講生が自習環境を作成したい場合も以下の手順にしたがってください。

1. AWS上に以下のプロトコルを許可するセキュリティグループを作成します。
  - 22
  - 80
  - 8000-8888
2. 上記のセキュリティグループを適用したインスタンスを起動します。
  - CentOS7(x86_64)
  - メモリ 2GB + (受講生 * 500MB)
  - ディスク 10GB + (受講生 * 1GB)
3. 作成したインスタンス上で以下を実行します。

```
sudo -i
curl -L https://git.io/jupyter -o setup.sh

# 作成したい人数を設定
NUM=01
bash ./setup.sh ${NUM:?}
```

4. 実行後に students.txt が作成され、ログイン情報が記載されています。このファイルの内容を受講生に配布してください。

5. 環境を削除するにはインスタンスごと削除してください。
