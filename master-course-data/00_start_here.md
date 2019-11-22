# AITAC インフラ自動化演習
---
本演習は、オープンソースソフトウェアである `Ansible` を題材として、最新のITインフラ自動化技術の基礎を習得することを目的とします。

## 演習に必要な環境
---
本演習では以下の環境を必要とします。

- AWSアカウント(アクセスキー、シークレットキー)
- インターネット接続可能なPC
- ブラウザ(最新版の Chrome を推奨、IEでは実施不可)

## 演習内容
---
以下の演習項目を指示に従い進めてください。各演習は自習可能な形態となっているため、インストラクターが不在でも進めることが可能です。

1. [演習の概要と環境の準備](01_overview_and_prepare_ec2.md)
2. [Ansible の基礎、インベントリー、認証情報](02_inv_cred.md)
3. [Ad-Hocコマンドとモジュール](03_adhoc_modules.md)
4. [Playbookの記述と実行](04_playbook.md)
5. [変数](05_variables.md)
6. [ループ、条件式、ハンドラー](06_loop_condition.md)
7. [エラーハンドリング](07_block_reduce.md)
8. [テンプレート](08_template.md)
9. [Roleによる部品化](09_role.md)
10. [Galaxy による Role 活用](10_galaxy.md)
11. [テストの自動化](11_testing.md)
12. [演習問題](12_exercises.md)
13. [演習環境のクリーンアップ](13_cleanup.md)

## 演習教材について
---
本演習環境の素材は以下で管理されています。

- [演習内容](https://github.com/irixjp/aitac-automation-handson)
- [演習用コンテナ](https://hub.docker.com/r/irixjp/aitac-automation-jupyter)、[Dockerfile](https://github.com/irixjp/aitac-automation-jupyter-docker)


本演習環境で利用しているソフトウェアは以下になります。

- [Ansible](https://github.com/ansible/ansible)
- [Jupyter Lab](https://github.com/jupyterlab/jupyterlab)


その他の参考文献&学習ソース

- [katacoda](https://www.katacoda.com/irixjp)
- [ansible official workshop](https://github.com/ansible/workshops)
