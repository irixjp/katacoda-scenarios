# Ad-Hoc Commands and Modules
---
In this section, You will learn about Module which is the important elements in Ansible and the Ad-hoc command to run the module.

![structure.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/structure.png)

## What is a Module?
---
A module is a "parts of common operations in infrastructure operations.". Anible has a huge number of modules. It's not an accurate expression, but it can also be called a "collection of libraries for infrastructure work.".

To write automation scripts can be simplified with the provision of modules. One example is the `dnf` module provided by Ansible.

The `dnf` module is the module that manages packages to the OS. You can install and remove packages by passing parameters to this module. Consider writing a shell script that does the same thing.

The simplest implementation is as follows:
```bash
function dnf_install () {
    PKG=$1
    dnf install -y ${PKG}
}
```
> Note: This script is for explanation and is not accurate.

This script is not sufficient for practical use. For example, you have to consider that the package you are trying to install is already installed. Then, the following should be true.

```bash
function dnf_install () {
    PKG=$1
    if [ Does this package already exist? ]; then
        exit 0
    else
        dnf install -y ${PKG}
    fi
}
```
> Note: This script is for explanation and is not accurate.

However, this is also not enough yet. If a package is already installed, what should I do if the version of the package is older, the same, or newer than what I'm going to install now? Extend the script to consider this case as well.

```bash
function dnf_install () {
    PKG=$1
    VERSION=$2
    if [ Does this package already exist? ]; then
        case ${VERSION} in
            lower ) dnf install -y ${PKG} ;;
            same ) exit 0
            higher ) exit 0
    else
        dnf install -y ${PKG}
    fi
}
```
> Note: This script is for explanation and is not accurate.

In this way, even the simple behavior of installing a package can lead to various considerations if you try to implement it from scratch, and you need to implement it to deal with them. As implementation increases, logic becomes complex, bugs become more likely, and maintenance costs increase. Moreover, the automation of these basic infrastructure operations is being done all over the world, and people are repeatedly reinventing the wheel on a daily basis, resulting in a huge amount of waste.

Ansible modules exist to eliminate this waste and aggregate everyone's knowledge for high quality infrastructure automation. The module includes "common infrastructure automation considerations" that enable users to implement automation without implementing detailed controls. In other words, you can avoid reinventing wheels and concentrate on the automation you want to implement, resulting in a significant reduction in automation descriptions.

## List of modules
---
Modules are managed in the form of `collection', and each collection contains multiple related modules. [List of Collections](https://docs.ansible.com/ansible/latest/collections/index.html) Find, install the collection you want to use and then use it.

> Note: Ansible up to version 2.9 included all modules by default, but the number of modules increased so much that it was changed to the current format (2.10 and later)

In the initial installation state, Ansible has only the `ansible.builtin` collection. A list of modules that are available in the ansible.builtin [click here](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html#modules) 

> Note: Handling of the Collection will be included in subsequent exercises.

You can see what modules are available in your environment with the `ansible-doc` command.
This command lists installed modules.

`ansible-doc -l`{{execute}}

```text
add_host        Add a host (and alternatively a group) to the ansible-playbook in-memory inventor...
apt             Manages apt-packages
apt_key         Add or remove an apt key
apt_repository  Add and remove APT repositories
assemble        Assemble configuration files from fragments
assert          Asserts given expressions are true
async_status    Obtain status of asynchronous task
blockinfile     Insert/update/remove a text block surrounded by marker lines
```
> Note: Proceed with f, return with b, end with q.

To view documentation for a specific module:

`ansible-doc dnf`{{execute}}

```text
> ANSIBLE.BUILTIN.DNF    (/opt/kata-materials/ansible/lib/python3.8/site-packages/ansible/modules/dnf.py)

        Installs, upgrade, removes, and lists packages and groups with the `dnf' package manager.
```
> Note: Proceed with f, return with b, end with q.

The module documentation provides a description of the parameters given to the module, the return values after the module is executed, and examples of actual usage.

> Note: Examples of module usage are very helpful.

## Ad-hoc command
---
You can call only one of these modules from Ansible to make Ansible do small things. This method is called the `Ad-hoc command`.

The command format is as follows:
```bash
$ ansible all -m <module_name> -a '<parameters>'
```

- `-m <module_name>`: Specifies the module name.
- `-a <parameters>`: Specifies the parameters to be passed to the module. In some cases, it can be optional.

Let's take advantage of the Ad-hoc command to get some modules working.

### ping
---
[`ping`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ping_module.html) Let's run the module. This is a module that determines whether Ansible can "communicate as Ansible" to the node it is working on (which is different from ICMP used in the network). Ping module parameters are optional.

`ansible all -m ping`{{execute}}

```text
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
Next, [`shell`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html) let's call the module. This  executes arbitrary commands on the node and retrieves the results.

`ansible all -m shell -a 'hostname'`{{execute}}

```text
node-1 | CHANGED | rc=0 >>
ip-10-0-0-92.ap-northeast-1.compute.internal

node-3 | CHANGED | rc=0 >>
ip-10-0-0-204.ap-northeast-1.compute.internal

node-2 | CHANGED | rc=0 >>
ip-10-0-0-218.ap-northeast-1.compute.internal
```

Please run a few other commands to see the results.

Get kernel information

`ansible all -m shell -a 'uname -a'`{{execute}}


Get a date

`ansible all -m shell -a 'date'`{{execute}}

Get disk usage

`ansible all -m shell -a 'df -h'`{{execute}}

Extract specific information from installed packages

`ansible all -m shell -a 'rpm -qa |grep bash'`{{execute}}


### dnf
---
[`dnf`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/dnf_module.html#ansible-collections-ansible-builtin-dnf-module) is the module that performs package operations. Try installing a new package using this module.

Install the screen package. First, verify that screen is not installed in your environment.

`ansible node-1 -m shell -a 'which screen'`{{execute}}

```text
node-1 | FAILED | rc=1 >>
which: no screen in (/home/centos/.local/bin:/home/centos/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin)non-zero return code
```

This command should fail because the screen does not exist.

Then, install screen using the dnf module.

`ansible node-1 -b -m dnf -a 'name=screen state=latest'`{{execute}}

```text
node-1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
        "Installed: screen-4.6.2-12.el8.x86_64"
    ]
}
```

- `-b`: become option. This is an option to operate on the node you are connecting to as root privileges. This option is added because installing the package requires root privileges. Otherwise, this command will be failed.

If you check the screen command again, it should succeed because the package is installed this time.

`ansible node-1 -m shell -a 'which screen'`{{execute}}

```text
node-1 | CHANGED | rc=0 >>
/usr/bin/screen
```

### setup
---
[`setup`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/setup_module.html) is a module that retrieves information about the target node. The retrieved information is automatically accessible under the variable name `ansible_xxx`.

Run on only one node because of the large amount of output.

`ansible node-1 -m setup`{{execute}}

In this way, Ansible has a variety of modules that can be used to operate nodes and collect information.

In the next exercise, you will use these modules to actually create a `Playbook`.