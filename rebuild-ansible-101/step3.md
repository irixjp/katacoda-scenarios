# Ad-Hocコマンドとモジュール
---
ここでは Ansible における重要な要素である `Module` と、モジュールを実行するための `Ad-hoc コマンド` について学習します。

![structure.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/master-course-data/assets/images/structure.png)

## モジュールとは
---
モジュールとは「インフラ作業でよくある操作を部品化」したものです。Ansible は約3000個のモジュールを標準で内蔵しています。正確な表現ではないですが、「インフラ作業におけるライブラリ集」だと言うこともできるかもしれません。

モジュールが提供されることで、自動化の記述をシンプルにすることができます。1つの例として、Ansible で提供される `yum` モジュールについて見てみます。

この `yum` モジュールはOSに対してパッケージの管理を行うモジュールです。このモジュールにパラメーターを渡すことでパッケージのインストールや削除を行うことができます。ここで、同じ動作をするシェルスクリプトを記述することを考えてみましょう。

最も単純に実装すると以下のようになります。
```bash
function yum_install () {
    PKG=$1
    yum install -y ${PKG}
}
```
> Note: スクリプト内容は動作を説明するためのもので正確ではありません

実際に利用するにはこのスクリプトでは不十分です。例えば、インストールしようとしたパッケージがすでにインストールされている場合を考慮しなければなりません。すると以下のようになるはずです。

```bash
function yum_install () {
    PKG=$1
    if [ Does this package already exist? ]; then
        exit 0
    else
        yum install -y ${PKG}
    fi
}
```
> Note: スクリプト内容は動作を説明するためのもので正確ではありません

しかし、まだこれでも不十分です。パッケージが既にインストールされているとして、そのパッケージのバージョンが、いまからインストールするものよりも古い、同じ、新しいといったケースではどうすればよいでしょうか？このケースも考慮するようにスクリプトを拡張しましょう。

```bash
function yum_install () {
    PKG=$1
    VERSION=$2
    if [ Does this package already exist? ]; then
        case ${VERSION} in
            lower ) yum install -y ${PKG} ;;
            same ) exit 0
            higher ) exit 0
    else
        yum install -y ${PKG}
    fi
}
```
> Note: スクリプト内容は動作を説明するためのもので正確ではありません

このように、パッケージをインストールという単純な動作でも、ゼロから実装しようとすると様々な考慮事項が発生し、それに対応するための実装が必要となっていきます。

そこで Ansible のモジュールには、あらかじめこのような考慮事項が組み込まれており、ユーザーは細かな制御を実装することなく自動化を利用可能になります。つまり、自動化の記述量を大幅に減らすことができます。

## モジュールの一覧
---
Ansible が持つモジュールの一覧は以下の[公式ドキュメント](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html) から確認できます。

別の方法として Ansible がインストールされた環境では、`ansible-doc` というコマンドでも参照することができます。

インストール済みのモジュールの一覧を表示するには以下のコマンドを実行します。

`ansible-doc -l`{{execute}}

> Note: space で進む、b で戻る、q で終了。

特定のモジュールのドキュメントを参照するには以下のように実行します。

`ansible-doc yum`{{execute}}

```bash
> YUM    (/usr/local/lib/python3.6/site-packages/ansible/modules/packaging/os/yum.py)

        Installs, upgrade, downgrades, removes, and lists packages and
        groups with the `yum' package manager. This module only works
        on Python 2. If you require Python 3 support see the [dnf]
        module.

  * This module is maintained by The Ansible Core Team
  * note: This module has a corresponding action plugin.
```

モジュールのドキュメントでは、モジュールに与えられるパラメーターの説明や、モジュールが実行された後の戻り値、そして実際の利用方法のサンプルが参照できます。

> Note: モジュールの利用方法のサンプルは非常に参考になります。

## Ad-hoc コマンド
---
先に紹介したモジュールを1つ呼び出して Ansible に小さな仕事を実行させることができます。この方法を `Ad-hoc コマンド` とよびます。

コマンドの形式は以下になります。

```bash
$ ansible all -m <module_name> -a '<parameters>'
```

- `-m <module_name>`: モジュール名を指定します。
- `-a <parameters>`: モジュールにわたすパラメーターを指定します。省略可能な場合もあります。

Ad-hoc コマンドを利用して、いくつかのモジュールを実際に動作させてみましょう。

### ping
---
[`ping`](https://docs.ansible.com/ansible/latest/modules/ping_module.html) モジュールを実行してみましょう。これは Ansible が操作対象のノードに対して「Ansible としての疎通」が可能かどうかを判定するモジュールです。パラメーターは省略可能です。

`ansible all -m ping`{{execute}}

```bash
node-1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
node-2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
node-3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
```


### shell
---
次に、[`shell`](https://docs.ansible.com/ansible/latest/modules/shell_module.html) モジュールを呼び出してみましょう。これは対象のノード上で任意のコマンドを実行し、その結果を回収するコマンドです。

`ansible all -m shell -a 'hostname'`{{execute}}

```bash
node-1 | CHANGED | rc=0 >>
ip-10-0-0-92.ap-northeast-1.compute.internal

node-3 | CHANGED | rc=0 >>
ip-10-0-0-204.ap-northeast-1.compute.internal

node-2 | CHANGED | rc=0 >>
ip-10-0-0-218.ap-northeast-1.compute.internal
```

他にもいくつかのコマンドを実行して結果を確かめてください。

`ansible all -m shell -a 'uname -a'`{{execute}}

`ansible all -m shell -a 'date'`{{execute}}

`ansible all -m shell -a 'df -h'`{{execute}}

`ansible all -m shell -a 'rpm -qa |grep bash'`{{execute}}


### yum
---
[`yum`](https://docs.ansible.com/ansible/latest/modules/yum_module.html)はパッケージの操作を行うモジュールです。このモジュールを利用して新しくパッケージをインストールしてみます。

今回は screen パッケージをインストールします。まず現在の環境に screen がインストールされていないことを確認します。

`ansible all -m shell -a 'which screen'`{{execute}}

このコマンドは screen が存在しないためエラーになるはずです。

では、 yum モジュールで screen のインストールを行います。

`ansible all -b -m yum -a 'name=screen state=latest'`{{execute}}

- `-b`: become オプション。これは接続先のノードでの操作に root 権限を利用するためのオプションです。パッケージのインストールには root 権限が必要となるため、このオプションをつけています。つけない場合、このコマンドは失敗します。

再度、screen コマンドの確認を行うと、今度はパッケージがインストールされたため成功するはずです。

`ansible all -m shell -a 'which screen'`{{execute}}

### setup
---
[`setup`](https://docs.ansible.com/ansible/latest/modules/setup_module.html) は対象ノードの情報を取得するモジュールです。取得された情報は `ansible_xxx` という変数名で自動的にアクセス可能となります。

出力される情報量が多いため、1台のノードのみに実行します。

`ansible node-1 -m setup`{{execute}}

このように Ansible は様々なモジュールを持ち、これらを使ってノードに対して操作を行ったり、情報収集を行うことが可能です。
