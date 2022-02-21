# Variables
---
Variables can be used to increase the versatility of a playbook. In this section, you will learn how to use various variables.

## Basics of Variables
---
Variables in Ansible have the following characteristics

- They have no type
- All are global variables (no scope)
- Can be defined/overwritten in many different places

Because they are all global variables and can be defined and overwritten in various ways, it is useful to have a naming convention that defines the usage policy within the team.

For more information on where variables can be defined and what priority they have, please refer to the [official documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable).

In this exercise, we will learn how to use a typical variable.

## debug module
---
To check the contents of the variables you have defined, the [`debug`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/debug_module.html)  module is useful.

Please edit `~/working/vars_debug_playbook.yml` as follows.

```yaml
---
- hosts: node-1
  gather_facts: no
  tasks:
    - name: print all variables
      debug:
        var: vars

    - name: get one variable
      debug:
        msg: "This value is {{ vars.ansible_version.full }}"
```

- `gather_facts: no` Ansible will by default run the `setup` module to gather information about the node being operated on and set it to a variable before running the task. You can set this variable to `no` to skip the information collection.  This is to make it easier to proceed with the exercise by reducing the amount of output of the variable list (the setup module collects a lot of information).
- `- debug:`
  - `var: vars` var option prints the contents of the variable given as an argument. Here we have given a variable named `vars` as an argument. `vars` is a special variable in which all variables are stored.
  - `msg: "This value is {{ vars.ansible_version.full }}"` msg option will output any string. In it, the parts enclosed by `{{ }}` are expanded as variables.
    - Dictionary data in the variable will be retrieved as `.keyname`.
    - List data in the variable is retrieved as `[index_number]`.

Execute `vars_debug_playbook.yml`.

`cd ~/working`{{execute}}

`ansible-playbook vars_debug_playbook.yml`{{execute}}

```text
PLAY [node-1] ****************************************

TASK [print all variables] ***************************
ok: [node-1] => {
    "vars": {
        (省略)
        "ansible_ssh_private_key_file": "/jupyter/aitac-automation-keypair.pem",
        "ansible_user": "centos",
        "ansible_verbosity": 0,
        "ansible_version": {
            "full": "2.9.0",
            "major": 2,
            "minor": 9,
            "revision": 0,
            "string": "2.9.0"
        },
        (省略)

TASK [get one variable] ******************************
ok: [node-1] => {
    "msg": "This value is 2.9.0"
}
(Snip)
```

The content of `vars` shows the [magic variables](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html) that Ansible defines by default.


## Define Variables in the Playbook
---
Now let's actually define the variables.

Please edit `~/working/vars_play_playbook.yml` as follows.

```yaml
---
- hosts: node-1
  gather_facts: no
  vars:
    play_vars:
      - order: 1st word
        value: ansible
      - order: 2nd word
        value: is
      - order: 3rd word
        value: fine
  tasks:
    - name: print play_vars
      debug:
        var: play_vars

    - name: access to the array
      debug:
        msg: "{{ play_vars[1].order }}"

    - name: join variables
      debug:
        msg: "{{ play_vars[0].value}} {{ play_vars[1].value }} {{ play_vars[2].value }}"
```

- `vars:` If you write a `vars:` section in the play part, variables can be defined under it.
  - `play_vars:` This is the variable name. You can set it freely.
    - As a value, this variable creates a list with three elements, one for each of which is a dictionary data with the key `order` `value`.
  - `msg: "{{ play_vars[1].order }}"` Retrieves the value of the list.
  - `msg: "{{ play_vars[0].value}} {{ play_vars[1].value }} {{ play_vars[2].value }}"` As shown in this example, it is also possible to combine the values of multiple variables.


Let's run `vars_play_playbook.yml`.

`cd ~/working`{{execute}}

`ansible-playbook vars_play_playbook.yml`{{execute}}

```text
(snip)
TASK [print play_vars] **************
ok: [node-1] => {
    "play_vars": [
        {
            "order": "1st word",
            "value": "ansible"
        },
        {
            "order": "2nd word",
            "value": "is"
        },
        {
            "order": "3rd word",
            "value": "fine"
        }
    ]
}

TASK [access to the array] **********
ok: [node-1] => {
    "msg": "2nd word"
}

TASK [join variables] ***************
ok: [node-1] => {
    "msg": "ansible is fine"
}
(snip)
```


## Defining Variables in the Task
---
It is possible to define variables to be used only within a single task, or to override them temporarily.

Let's edit `~/working/vars_task_playbook.yml` as follows.

```yaml
---
- hosts: node-1
  gather_facts: no
  vars:
    task_vars: 100
  tasks:
    - name: print task_vars 1
      debug:
        var: task_vars

    - name: override task_vars
      debug:
        var: task_vars
      vars:
        task_vars: 20

    - name: print task_vars 2
      debug:
        var: task_vars
```

Execute `vars_task_playbook.yml`.

`ansible-playbook vars_task_playbook.yml`{{execute}}

```text
(snip)
TASK [print task_vars 1] ************
ok: [node-1] => {
    "task_vars": 100
}

TASK [override task_vars] ***********
ok: [node-1] => {
    "task_vars": 20
}

TASK [print task_vars 2] ************
ok: [node-1] => {
    "task_vars": 100
}
```

A `vars:` in a task is a variable that is valid only in that task. Since [priority of the variable](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) is higher than `play vars`, the second task will overwrite the value of the variable, resulting in the above.

Now let's check what happens if we use `extra_vars` (a variable specified from the command line), which has even higher priority.

To give `extra_vars`, run the `ansible-playbook` command with the `-e` option.

`ansible-playbook vars_task_playbook.yml -e 'task_vars=50'`{{execute}}

```text
(snip)
TASK [print task_vars 1] ************
ok: [node-1] => {
    "task_vars": "50"
}

TASK [override task_vars] ***********
ok: [node-1] => {
    "task_vars": "50"
}

TASK [print task_vars 2] ************
ok: [node-1] => {
    "task_vars": "50"
}
```

In all tasks, the value of `extra_vars` with the highest priority is used. As you can check, Ansible has different priorities for overwriting variables depending on where they are defined, so be careful.

## Other Variable Definitions
---
Here are some other ways to define variables.


### Definition in set\fact
---
 [set_fact] (https://docs.ansible.com/ansible/latest/collections/ansible/builtin/set_fact_module.html) module can be used to define arbitrary variables in a task part. A common use is to receive the result of the execution of one task, process the value to define a new variable, and use the value in a subsequent task.

The exercise on using `set_fact` will be given in the next part.


### Definition in host\_vars, group\_vars
---
iThese are the variables described in the inventory section. You can define variables to be associated with specific groups or hosts.
In addition to writing them in the inventory file, you can also create a `gourp_vars` `host_vars` directory in the same directory layer as the playbook to be executed. By creating `<group_name>.yml` and `<node_name>.yml` files in the `host_vars` directory, Ansible make them recognized as group and host variables.

>Note: The directory names `gourp_vars` `host_vars` are predefined in Ansible and cannot be changed

We will actually define some host variables and group variables.

### `~/working/group_vars/all.yml` 

Let's define the group variables.

```yaml
---
vars_by_group_vars: 1000
```

### `~/working/host_vars/node-1.yml` 

Define the host variables for node-1.

```yaml
---
vars_by_host_vars: 111
```

### `~/working/host_vars/node-2.yml`

Define the host variables for node-2.

```yaml
---
vars_by_host_vars: 222
```

### `~/working/host_vars/node-3.yml`

Define the host variables for node-3.

```yaml
---
vars_by_host_vars: 333
```

### Check Variable Files

Let's check the files we have created so far.

`tree group_vars host_vars`{{execute}}

```text
group_vars
└── all.yml     <- vars_by_group_vars: 1000
host_vars
├── node-1.yml  <- vars_by_host_vars: 111
├── node-2.yml  <- vars_by_host_vars: 222
└── node-3.yml  <- vars_by_host_vars: 333
```


### `~/working/vars_host_group_playbook.yml`

Let's create a playbook that uses these variables.

```yaml
---
- hosts: all
  gather_facts: no
  tasks:
    - name: print group_vars
      debug:
        var: vars_by_group_vars

    - name: print host vars
      debug:
        var: vars_by_host_vars

    - name: vars_by_group_vars + vars_by_host_vars
      set_fact:
        cal_result: "{{ vars_by_group_vars + vars_by_host_vars }}"

    - name: print cal_vars
      debug:
        var: cal_result
```

When you are ready, execute `vars_host_group_playbook.yml`.

`ansible-playbook vars_host_group_playbook.yml`{{execute}}

```text
(snip)
TASK [print group_vars] ******************************
ok: [node-1] => {
    "vars_by_group_vars": 1000
}
ok: [node-2] => {
    "vars_by_group_vars": 1000
}
ok: [node-3] => {
    "vars_by_group_vars": 1000
}

TASK [print host vars] *******************************
ok: [node-1] => {
    "vars_by_host_vars": 111
}
ok: [node-2] => {
    "vars_by_host_vars": 222
}
ok: [node-3] => {
    "vars_by_host_vars": 333
}

TASK [vars_by_group_vars + vars_by_host_vars] ********
ok: [node-1]
ok: [node-2]
ok: [node-3]

TASK [print cal_vars] ********************************
ok: [node-1] => {
    "cal_result": "1111"
}
ok: [node-2] => {
    "cal_result": "1222"
}
ok: [node-3] => {
    "cal_result": "1333"
}
(snip)
```

In this way, it is possible to have different values for different groups or hosts with the same variable name.


### Save Execution Results by Register
---
Ansible modules return various return values when executed, and in the playbook, these return values can be saved for use in subsequent tasks. The `register` clause is used for this purpose, and if a variable name is specified in `register`, the return value will be stored in that variable.

Edit `~/working/vars_register_playbook.yml` as follows.

```yaml
---
- hosts: node-1
  gather_facts: no
  tasks:
    - name: exec hostname command
      shell: hostname
      register: ret

    - name: print ret
      debug:
        var: ret

    - name: create a directory
      file:
        path: /tmp/testdir
        state: directory
        mode: '0755'
      register: ret

    - name: print ret
      debug:
        var: ret
```


Let's execute `vars_register_playbook.yml`.

`ansible-playbook vars_register_playbook.yml`{{execute}}

```text
(snip)
TASK [exec hostname command] *************************
changed: [node-1]

TASK [print ret] *************************************
ok: [node-1] => {
    "ret": {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python"
        },
        "changed": true,
        "cmd": "hostname",
        "delta": "0:00:00.005958",
        "end": "2019-11-17 14:02:44.892010",
        "failed": false,
        "rc": 0,
        "start": "2019-11-17 14:02:44.886052",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "ip-10-0-0-92.ap-northeast-1.compute.internal",
        "stdout_lines": [
            "ip-10-0-0-92.ap-northeast-1.compute.internal"
        ]
    }
}

TASK [create a directory] ****************************
changed: [node-1]

TASK [print ret] *************************************
ok: [node-1] => {
    "ret": {
        "changed": true,
        "diff": {
            "after": {
                "mode": "0755",
                "path": "/tmp/testdir",
                "state": "directory"
            },
            "before": {
                "mode": "0775",
                "path": "/tmp/testdir",
                "state": "absent"
            }
        },
        "failed": false,
        "gid": 1000,
        "group": "centos",
        "mode": "0755",
        "owner": "centos",
        "path": "/tmp/testdir",
        "secontext": "unconfined_u:object_r:user_tmp_t:s0",
        "size": 6,
        "state": "directory",
        "uid": 1000
    }
}
```

In this example, we first use the `shell` module to store the result of executing the hostname command in the variable `ret`, and display the contents in the `debug` module immediately after. Next, a directory is created using the [`file`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html) module and its return value is stored in `ret`. Then, the `debug` module is used to check the contents.

You can confirm what the return value of each module is in the module documentation.

The use of variables gives a lot of flexibility to the playbook.Let's continue to learn about loops, conditionals and combinations, which will come later.

## Answers to the Exercises
---
- [vars\_debug\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/vars_debug_playbook.yml)
- [vars\_play\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/vars_play_playbook.yml)
- [vars\_task\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/vars_task_playbook.yml)
- [vars\_host\_group\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/vars_host_group_playbook.yml)
  - [host\_vars/node-1.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/host_vars/node-1.yml)
  - [host\_vars/node-2.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/host_vars/node-2.yml)
  - [host\_vars/node-3.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/host_vars/node-3.yml)
  - [group\_vars/all.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/group_vars/all.yml)
- [vars\_register\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/vars_register_playbook.yml)
