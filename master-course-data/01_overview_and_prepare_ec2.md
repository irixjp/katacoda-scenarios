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

ターミナルから以下のコマンドを実行します。上記の値の入力を求められますので、各自「**自分に割り当てられた値**」を入力してください。以下のサンプル値を入力しても演習は行なえませんので注意してください。

> Note: ここで入力するAWSの情報は、この演習用に事務局から配布されたアカウント情報を利用してください。

`aws configure`{{execute}}

```bash
AWS Access Key ID [None]: AABBCCDDEEFFGG ← 自分のアクセスキー
AWS Secret Access Key [None]: AABBCCDDEEFFGGHHIIJJKKLLMMNN ← 自分のシークレットキー
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

> Note: エラーが出た場合の対処(AMIのサブスクリプションを保持していない場合に出ます)

受講者の環境によっては以下のようなエラーが出る場合があります。

```
TASK [Create instances] ********************************************************
fatal: [localhost]: FAILED! => {"changed": false, "msg": "Instance creation failed => OptInRequired: In order to use this AWS Marketplace product you need to accept terms and subscribe. To do so please visit https://aws.amazon.com/marketplace/pp?sku=xxxxxyyyyyyzzzzzzzzzzz"}

PLAY RECAP *********************************************************************
localhost                  : ok=16   changed=7    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
```

このエラーは演習で使うAWSのOSイメージが利用可能な状態になっていないと出ます。以下の手順でイメージを有効化してください。

1. AWSコンソールから一度ログオフする（ログインしている場合）
2. エラーメッセージに表示されたURLへアクセスする
  - 上記の例では `https://aws.amazon.com/marketplace/pp?sku=xxxxxyyyyyyzzzzzzzzzzz`
3. 画面の「Subscribe」 → 「Accept」として CentOS7 のイメージを有効にします。
  - AWS側の画面のアップデートで文言が変わっている場合もあります。
  - ここでログインを求められますので、本演習用に配布されたアカウント情報でログインしてください。
4. Jupyterコンソールに戻り、`ansible-playbook ec2_prepare.yml` を再実行します。


もしその他のエラーとなった場合には講師に確認を行ってください。

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

> Note: アクセス情報を配布するために Etherpad を利用するのが便利です。

```
EP_USER=username
EP_PASS=password

docker run -d -p 8443:8443 --name eplite -e EP_USER=${EP_USER:?} -e EP_PASS=${EP_PASS:?} irixjp/eplite:latest
```

5. 環境を削除するにはインスタンスごと削除してください。
