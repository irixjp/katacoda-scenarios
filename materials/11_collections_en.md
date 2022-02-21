# Collections
---
`Collection` takes the Galaxy reuse mechanism one step further. It allows you to manage and distribute multiple roles and custom modules together and is available in Ansible 2.9 and later (and experimentally since 2.8). Previously, one role and one repository could be managed, but now common functions used by organizations and teams can be managed together in one repository.

In addition, since Ansible 2.10, a large number of built-in modules have been separated and made into collections that can be downloaded and used as needed.

## Collection Type
---
Collections can be broadly categorized as follows

- [Community Collections](https://docs.ansible.com/ansible/latest/collections/index.html): Widely recognized and used, and linked by the Ansible community (not necessarily certified). Can be installed from Galaxy.
- [Certified Collections](https://access.redhat.com/articles/3642632): Collections supported by Red Hat (available with purchase of Ansible Automation Platform). Can be installed from Automation Hub.
- [Other Collections](https://galaxy.ansible.com/): A large collection of other collections developed by individuals and companies. Can be installed from Galaxy or github etc.


## Install from the command line
---
In order to use the Collection, you need to install it first. The easiest way is to use the command line.

Before we do that, let's check the currently installed collection. Please execute the following.

`ansible-galaxy collection list`{{execute}}

```text
# /root/.ansible/collections/ansible_collections
Collection       Version
---------------- -------
community.crypto 1.7.1
community.docker 1.8.0 
```

You should be able to see that some collections are already installed.

> Note: The installed collections and versions may vary depending on your environment, but this will not affect the exercise.

> Note: The collection name should be `<namespace>. <collection_name>`.

Check the number of modules available in this state.

`ansible-doc -l | wc -l`{{execute}}

This command will display a number, so make a note of the value (you may get a warning, but ignore it).

Now let's install a new collection [`cisco.ios`](https://docs.ansible.com/ansible/latest/collections/cisco/ios/index.html) .  It contains a set of modules that control Cisco's network equipment.

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

By default, this command will connect to `galaxy.ansible.com` to download the collection. It is also possible to change the destination to another site. It also resolves collection dependencies and installs the related collections at the same time.

Let's check the installed collections.

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

You should be able to see that the dependencies have been resolved and multiple collections have been installed.

There should be more modules available. Let's check it.

`ansible-doc -l | wc -l`{{execute}}

The downloaded collections will be saved to `~/.ansible/collections/ansible_collections/` by default.

`ls -alF ~/.ansible/collections/ansible_collections/`{{execute}}

```text
total 20
drwxr-xr-x 5 root root 4096 Oct  9 13:15 ./
drwxr-xr-x 3 root root 4096 Oct  9 13:12 ../
drwxr-xr-x 4 root root 4096 Oct  9 13:15 ansible/
drwxr-xr-x 3 root root 4096 Oct  9 13:15 cisco/
drwxr-xr-x 4 root root 4096 Oct  9 13:12 community/
```

To change the installation directory, specify the directory with the option `-p`. However, if you want to refer to a collection in the Playbook after installation, the directory must be included in [`COLLECTIONS_PATHS`](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#collections-paths).

There is no uninstall command, so if you want to remove a collection, just delete the collection directory.


`rm -rf ~/.ansible/collections/ansible_collections/{ansible,cisco}`{{execute}}

`ls -alF ~/.ansible/collections/ansible_collections/`{{execute}}

```text
total 12
drwxr-xr-x 5 root root 4096 Oct  9 13:15 ./
drwxr-xr-x 3 root root 4096 Oct  9 13:12 ../
drwxr-xr-x 4 root root 4096 Oct  9 13:12 community/
```

We'll check if it's been deleted.

`ansible-galaxy collection list`{{execute}}

```text
# /root/.ansible/collections/ansible_collections
Collection        Version
----------------- -------
community.crypto  1.7.1
community.docker  1.8.0
```

The number of available modules should also be reduced.

`ansible-doc -l | wc -l`{{execute}}

You can also specify the version of the collection to install. During installation, specify `<namespace>. <collection_name>:<version>`. (if you do not specify the version, the latest version will be installed).

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

You can confirm that the specified version has been installed. The version that can be specified for installation can be found in the distribution source. In this case. Let's check [cisco.ios distributor](https://galaxy.ansible.com/cisco/ios) .


## Install from requirements.yml
---
Similar to roles, collections can be installed using `requirements.yml`. List the collections (and versions if necessary) that you want to use in your Playbook, and get them all at once.

In this example, we will install a sample collection[https://galaxy.ansible.com/irixjp/sample\_collection\_hello](https://galaxy.ansible.com/irixjp/sample_collection_hello)  that has already been created.
The name of this collection is `irixjp.sample_collection_hello`. The original source code is stored at [github](https://github.com/irixjp/ansible-sample-collection-hello).

This collection contains the following

- role: hello
- role: uptime
- module: sample\_get\_hello

To use a collection, create a `requirements.yml`.

Please edit `~/working/collections/requirements.yml` as follows.

```yaml
---
collections:
- name: irixjp.sample_collection_hello
  version: 1.0.0
```

To retrieve the collection, please execute the following.

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


We will create a playbook that uses the retrieved collection. Access to the collection is done in the following format.

`<namespace>.<collection_name>.<role or module name>`

This method is called FQCN (fully qualified collection name).

> Note: Originally, modules should always be specified with FQCN, but since the concept of collection did not exist in previous Ansible versions, it is currently possible to invoke them with just the module name to maintain compatibility. This is because Ansible has a table [plugin\_routing](https://github.com/ansible/ansible/blob/devel/lib/ansible/config/ansible_builtin_runtime.yml) that automatically converts past module names to FQCN when they are called. Therefore, if a module does not exist in this table, it can only be called with FQCN. For the future, it is safer to write them in FQCN.

Edit `~/working/collection_playbook.yml` as follows.

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

Let's check the execution result.

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

You can see that each role and module in the collection is being called. Compared to installing a single role with galaxy, it is possible to call a custom module by itself. This makes it even more convenient.

## Supplemental Information
---
iIf necessary, please also check the following.

- More detailed usage: [Using collections](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)
- How to create a collection: [Developing collections](https://docs.ansible.com/ansible/devel/dev_guide/developing_collections.html)

On the command line, you need to run `ansible-galaxy collection install` every time. However, Ansible Automation Platform and AWX have a feature to automatically download the required collections from `requirements.yml` before running the playbook, which can prevent accidents such as forgetting to update.


## Answers to the Exercises
---
- [collection\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/collection_playbook.yml)
- [collections/requirements.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/collections/requirements.yml)
