# 演習問題
---
以下の演習を実施してください。

演習では各サーバーにhttpdの設定が行われているため、以下のコマンドを実行して環境をクリアしてください。課題の途中で演習環境をクリアする場合にも利用できます。

`cd ~/working`{{execute}}

`ansible web -b -m yum -a 'name=httpd state=absent'`{{execute}}

`ansible web -b -m file -a 'path=/var/www/html/index.html state=absent'`{{execute}}

`ansible web -b -m yum -a 'name=epel-release state=absent'`{{execute}}

`ansible web -b -m yum -a 'name=nginx state=absent'`{{execute}}


## 問題1
---
下記の機能を持つロール `httpd_myip` 作成してください。

- ロールのディレクトリは `~/working/roles/httpd_myip` に配置します。
- このロールは httpd をインストールし、起動状態にします。
- トップページに index.html を配置し、このページは設定したホストのIPアドレスが表示されるように設定します。


## 問題2
---
下記の機能を持つロール `nginx_lb` を作成してください。

- ロールのディレクトリは `~/working/roles/nginx_lb` に配置します。
- このロールは変数 `backend_server_list` にIPアドレスのリストを取ります。
  - `backend_server_list` はデフォルト値は空リスト `[]` とします。
- このロールはサーバーに `nginx` をインストールし、以下の設定を行います。
  - インストールに使用するパッケージはEPELから取得してください。
- `backend_server_list` にセットされたIPアドレスのポート80へ、ロードバランサとして動作させます。


## 問題3
---
下記の設定を行うPlaybook `~/working/lb_web.yml` を `httpd_myip` と `nginx_lb` ロールを使って作成してください。

- 演習環境3台を以下のように設定してください。
  - 2台に `httpd` を適用してWEBサーバーとして設定する。
  - 1台に `rp_nginx` を適用してロードバランサとして設定する。
  - 上記の設定のために必要であればインベントリーファイルを編集してください(必須ではありません)
- ロードバランサは2台のWEBサーバーに対して負荷分散を行います。
  - ロードバランサにアクセスすると交互にWEBサーバーのページが表示されること。

## 解答例
---
- [httpd_myip](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/roles/httpd_myip)
- [nginx_lb](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/roles/nginx_lb)
- [lb_web.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/lb_web.yml)
