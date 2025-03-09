[14scenarios on Killercoda](https://killercoda.com/ansible "Get your profile on killercoda.com")

このリポジトリにはAnsibleの演習コンテンツが格納されています。特にこれからAnsibleによる自動化を学習しようとする人に最適なコンテンツとなっています。

This repository contains the contents of Ansible exercises. It is especially suitable for those who are learning automation with Ansible.


この演習を実施するには [Killercoda](https://killercoda.com/ansible) を利用するのが最も簡単です。知識のある方はAWS上に演習環境を構築することもできます。

The easiest way to run this exercise is to use Killercoda. If you are knowledgeable, you can also build your own training environment on AWS.


本リポジトリのドキュメントやコードは [MITライセンス](./LICENSE) で公開されています。

The documentation and code in this repository are released under the [MIT license](./LICENSE).


## Killercoda 上の演習実施回数 / Number of exercises run on Killercoda
(./setup.sh の実行回数をカウントしています / . /setup.sh is counted)

![result-kata.png](http://www.emacs-lisp.net/materials/kata.png)

> Note: たまに表示されないことがあります。 / Sometimes it is not displayed.


## AWS上での環境構築方法 / How to build an environment on AWS

[./materials/99_ec2_setup.md](./materials/99_ec2_setup.md) をご確認ください。


## リポジトリの構造 / Structure of the repository

``` text
├── Dockerfile          (deprecated) for 2.9
├── License             License Description
├── README.md           This file
├── ansible-101         killercoda course for Japanese
├── ansible-102         killercoda course for Japanese
├── ansible-103         killercoda course for Japanese
├── ansible-104         killercoda course for Japanese
├── ansible-en-101      killercoda course for English
├── ansible-en-102      killercoda course for English
├── ansible-en-103      killercoda course for English
├── ansible-en-104      killercoda course for English
├── ansible-playground  killercoda ansible playground
├── assets              Author's icon
├── container           Container definition for target nodes
├── master-course-data  (deprecated) for 2.9
├── materials           Course Documentation(main contents)
├── old_ansible-2.9-101 (deprecated) for 2.9
├── old_ansible-2.9-102 (deprecated) for 2.9
├── old_ansible-2.9-103 (deprecated) for 2.9
├── old_ansible-2.9-104 (deprecated) for 2.9
├── old_ansible-2.9-playground (deprecated) for 2.9
├── sandbox             test environments
└── tools               Scripts for building an exercise environment
```

新しいコースを追加するには / To add a new course

1. `materials` にコースドキュメントを格納する
1. その後 `ansible-xxx` を作成して、`index.json` を追加してコースの作成する
1. 必要なドキュメントへのシンボリックリンクを作成する。

1. Store the course documentation in `materials`.
1. Then create `ansible-xxx` and add `index.json` to create the course.
1. Create symbolic links to the required documents.
