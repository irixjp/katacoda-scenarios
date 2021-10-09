# Collections
---
`Collection` は Galaxy の再利用の仕組みを更に一歩進めたものです。複数のロールやカスタムモジュールをまとめて管理し配布することが可能です。Ansible 2.9 以降(2.8から実験的には利用可能)で利用できます。従来は1ロール1リポジトリで管理していたものを、組織やチームで利用する共通機能をまとめて1リポジトリで管理できるようになります。

またAnsible 2.10 以降ではビルトインされていた大量のモジュールが分離され、Collection として必要に応じてダウンロードして利用する形式となっています。

## Collection の種類
---
Collection の配布方法は大きく分類すると以下のようになります。

- [Community Collections](https://docs.ansible.com/ansible/latest/collections/index.html): 広く認知され活用されており、Ansible コミュニティからもリンクされている（認定等があるわけではない）
- [Certified Collections](https://access.redhat.com/articles/3642632): Red Hat 社によりサポートされるコレクション(Ansible Automation Platform を購入することで利用可能となる)
- [その他のCollections](https://galaxy.ansible.com/): 個人や企業によって開発された上記以外の膨大なコレクション。

上記以外にも、個人が github 上で公開しているものや、企業が独自に準備しているコレクションも存在しています。

## コマンドラインからのインストール
---
Collection を利用するには先ずインストールを行う必要があります。最も簡単な方法はコマンドラインを利用する方法です。

その前に、現在インストールされているコレクションを確認してみましょう。以下を実行します。

`ansible-galaxy collection list`{{execute}}

```text
# /root/.ansible/collections/ansible_collections
Collection       Version
---------------- -------
community.crypto 1.7.1
community.docker 1.8.0 
```

既にいくつかのコレクションがインストールされていることが確認できるはずです。

> Note: インストールされているコレクションやバージョンは環境によって異なる可能性がありますが演習には影響ありません。

> Note: コレクション名は `<namespace>.<collection_name>` という形式で表現されます。

またこの状態で利用可能なモジュールの数を確認しておきます。

`ansible-doc -l | wc -l`{{execute}}

このコマンドで数字が表示されるので、その値をメモしていてください（警告が表示される場合もありますが無視してください）

ここに新たなコレクション [`cisco.ios`](https://docs.ansible.com/ansible/latest/collections/cisco/ios/index.html) をインストールしてみます。

`ansible-galaxy collection install cisco.ios`{{execute}}

```text
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/cisco-ios-2.5.0.tar.gz to /root/.ansible/tmp/ansible-local-6569oell9yke/tmprvdhd5sg/cisco-ios-2.5.0-4w06ahwz
Installing 'cisco.ios:2.5.0' to '/root/.ansible/collections/ansible_collections/cisco/ios'
Downloading https://galaxy.ansible.com/download/ansible-netcommon-2.4.0.tar.gz to /root/.ansible/tmp/ansible-local-6569oell9yke/tmprvdhd5sg/ansible-netcommon-2.4.0-obylwy_7
cisco.ios:2.5.0 was installed successfully
Installing 'ansible.netcommon:2.4.0' to '/root/.ansible/collections/ansible_collections/ansible/netcommon'
Downloading https://galaxy.ansible.com/download/ansible-utils-2.4.2.tar.gz to /root/.ansible/tmp/ansible-local-6569oell9yke/tmprvdhd5sg/ansible-utils-2.4.2-c3ygo8lk
ansible.netcommon:2.4.0 was installed successfully
Installing 'ansible.utils:2.4.2' to '/root/.ansible/collections/ansible_collections/ansible/utils'
ansible.utils:2.4.2 was installed successfully
```

このコマンドを実行すると、デフォルトで `galaxy.ansible.com` へ接続してコレクションをダウンロードします。接続先を他のサイトへと変更することも可能です。またインストール時にはコレクションの依存関係を解決し、関連するコレクションも同時にインストールされます。

インストールされたコレクションを確認します。

`ansible-galaxy collection list`{{execute}}

```text
# /root/.ansible/collections/ansible_collections
Collection        Version
----------------- -------
ansible.netcommon 2.4.0
ansible.utils     2.4.2
cisco.ios         2.5.0
community.crypto  1.7.1
community.docker  1.8.0
```

依存関係の解決で、複数のコレクションがインストールされていることが確認できるはずです。

利用可能なモジュールが増えているはずです。確認しておきましょう。

`ansible-doc -l | wc -l`{{execute}}

ダウンロードされたコレクションはデフォルトで `~/.ansible/collections/ansible_collections/` へと保存されます。

`ls -alF ~/.ansible/collections/ansible_collections/`{{execute}}

```text
total 20
drwxr-xr-x 5 root root 4096 Oct  9 13:15 ./
drwxr-xr-x 3 root root 4096 Oct  9 13:12 ../
drwxr-xr-x 4 root root 4096 Oct  9 13:15 ansible/
drwxr-xr-x 3 root root 4096 Oct  9 13:15 cisco/
drwxr-xr-x 4 root root 4096 Oct  9 13:12 community/
```

インストール先を変える時にはオプション `-p` をつけてディレクトリを指定します。ただし、インストール後にコレクションを Playbook から参照するには [`COLLECTIONS_PATHS`](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#collections-paths) にそのディレクトリが含まれている必要があります。

アンインストールするコマンドはありませんので、コレクションを削除したい場合にはコレクションのディレクトリを削除します。

`rm -rf ~/.ansible/collections/ansible_collections/{ansible,cisco}`{{execute}}

`ls -alF ~/.ansible/collections/ansible_collections/`{{execute}}

```text
total 12
drwxr-xr-x 5 root root 4096 Oct  9 13:15 ./
drwxr-xr-x 3 root root 4096 Oct  9 13:12 ../
drwxr-xr-x 4 root root 4096 Oct  9 13:12 community/
```

削除されたか確認しておきます。

`ansible-galaxy collection list`{{execute}}

```text
# /root/.ansible/collections/ansible_collections
Collection        Version
----------------- -------
community.crypto  1.7.1
community.docker  1.8.0
```

利用可能なモジュール数も減っているはずです。

`ansible-doc -l | wc -l`{{execute}}

コレクションのインストールにはコレクションのバージョンを指定することも可能です。インストール時に `<namespace>.<collection_name>:<version>` と指定します(バージョンを指定しなかった場合は最新版がインストールされます)

`ansible-galaxy collection install cisco.ios:2.3.1`{{execute}}`

`ansible-galaxy collection list`{{execute}}

```text
# /root/.ansible/collections/ansible_collections
Collection        Version
----------------- -------
ansible.netcommon 2.4.0
ansible.utils     2.4.2
cisco.ios         2.3.1
community.crypto  1.7.1
community.docker  1.8.0
```

指定されたバージョンがインストールされたことが確認できます。インストールに指定できるバージョンは配布元で確認できます。今回の [cisco.ios の配布元](https://galaxy.ansible.com/cisco/ios) を確認してみましょう。


## requirements.yml からのインストール
---
ロールと同様にコレクションも `requirements.yml` を利用してインストールが可能です。自分のPlaybookで利用するコレクション(と必要に応じてバージョン)を列挙しておき、一括で取得します。

ここでは既に作成済みのサンプルコレクション [https://galaxy.ansible.com/irixjp/sample\_collection\_hello](https://galaxy.ansible.com/irixjp/sample_collection_hello) をインストールしてみます。このコレクション名は `irixjp.sample_collection_hello` です。オリジナルのソースコードは [github](https://github.com/irixjp/ansible-sample-collection-hello) に格納されています。

このコレクションは以下を含んでいます。

- role: hello
- role: uptime
- module: sample\_get\_hello

コレクションを利用するには、`requirements.yml` を作成します。

`~/working/collections/requirements.yml` を以下のように編集します。

```yaml
---
collections:
- name: irixjp.sample_collection_hello
  version: 1.0.0
```

コレクションを取得するには以下を実行します。

`cd ~/working`{{execute}}

`ansible-galaxy collection install -r collections/requirements.yml`{{execute}}

`ansible-galaxy collection list`{{execute}}

```text
# /root/.ansible/collections/ansible_collections
Collection                     Version
------------------------------ -------
ansible.netcommon              2.4.0
ansible.utils                  2.4.2
cisco.ios                      2.3.1
community.crypto               1.7.1
community.docker               1.8.0
irixjp.sample_collection_hello 1.0.0
```


取得したコレクションを利用する playbook を作成します。コレクションへのアクセスは以下の形式で行います。

`<namespace>.<collection_name>.<role or module name>`

この指定方法を FQCN (fully qualified collection name) と呼びます。

> Note: 本来、モジュールの指定は常にFQCNで行う必要がありますが、過去のAnsibleバージョンにはコレクションという概念が存在しなかったため、互換性維持のために現在のところモジュール名のみでも呼び出し可能になっています。これはAnsible内部で過去のモジュール名が呼び出された際に自動的にFQCNへと変換するテーブル [plugin\_routing](https://github.com/ansible/ansible/blob/devel/lib/ansible/config/ansible_builtin_runtime.yml) が準備されているためです。そのため、このテーブルに存在しないモジュールの場合は FQCN でしか呼び出すことができなくなっています。今後のことを考えた場合は FQCN で記述しておくのが安全です。

`~/working/collection_playbook.yml` を以下のように編集します。

```yaml
---
- name: using collection
  hosts: node-1
  tasks:
    - import_role:
        name: irixjp.sample_collection_hello.hello

    - import_role:
        name: irixjp.sample_collection_hello.uptime

    - name: get locale
      irixjp.sample_collection_hello.sample_get_locale:
      register: ret

    - debug: var=ret
```

実行結果を確認します。

`ansible-playbook collection_playbook.yml`{{execute}}

```text
TASK [hello : say hello! (C)] **************
ok: [node-1] => {
    "msg": "Hello"
}

TASK [uptime : get uptime] *****************
ok: [node-1]

TASK [uptime : debug] **********************
ok: [node-1] => {
    "msg": " 03:38:16 up 4 days, 23:01,  1 user,  load average: 0.16, 0.05, 0.06"
}

TASK [get locale] **************************
ok: [node-1]

TASK [debug] *******************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "failed": false,
        "locale": "C.UTF-8"
    }
}
```

コレクション内の各ロール、モジュールを呼出していることが確認できます。単体のロールをgalaxyでインストールした時と比べて、カスタムモジュールを単体で呼び出すことも可能になっており、更に利便性が向上しています。

## 補足情報
---
必要に応じて以下も確認してください。

- より詳細な利用方法: [Using collections](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)
- コレクションを作成する方法: [Developing collections](https://docs.ansible.com/ansible/devel/dev_guide/developing_collections.html)

コマンドラインでは `ansible-galaxy collection install` をつど実行する必要がありますが、Ansible Automation Platform や AWX では playbook の実行前に自動的に `requirements.yml` から必要なコレクションをダウンロードする機能がありますので、更新し忘れといった事故を防止することが可能です。


## 演習の解答
---
- [collection\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/collection_playbook.yml)
- [collections/requirements.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/collections/requirements.yml)
