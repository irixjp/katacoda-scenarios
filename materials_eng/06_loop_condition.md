# Loop, Conditional Expression, Handler
---
Since playbooks are written in YAML format, tasks and parameters are basically represented as "data". However, sometimes using programming expressions is more concise in describing tasks, and Ansible has the functionality for this. In this exercise, we will look at the "function as a programming" of the playbook.

## Loop
---
Used to perform specific tasks repeatedly. For example, let's look at a playbook that creates three OS users: `apple`, `orange`, `pineapple`. The [`user`](https://docs.ansible.com/ansible/latest/modules/user_module.html) module is available to add users, so you can write a playbook like the one below.

```yaml
---
- name: add three users individually
  hosts: node-1
  become: yes
  tasks:
    - name: add apple user
      user:
        name: apple
        state: present

    - name: add orange user
      user:
        name: orange
        state: present

    - name: add pineapple user
      user:
        name: pineapple
        state: present
```

This playbook works to add three users exactly as intended. However, this method is redundant because the same description must be repeated over and over again. If the specifications of the `user` module change, the way parameters are given, or if you want the user you create later to have additional information, you must edit each task.

The `loop` clause can be used for this kind of repeated process.

Edit `~/working/loop_playbook.yml` as follows.

```yaml
---
- name: add users by loop
  hosts: node-1
  become: yes
  vars:
    user_list:
      - apple
      - orange
      - pineapple
  tasks:
    - name: add a user
      user:
        name: "{{ item }}"
        state: present
      loop: "{{ user_list }}"
```

- `vars: user_list` Define the variable `user_list` to define a list with three elements: apple, orange, and pineapple.
- `loop: "{{ user_list }}"` Add a loop clause to the task and give a list to parameters, the task will be repeated for only a number of elements.
- `name: "{{ item }}"` An item variable is a variable that is only available in a loop and contains the retrieved variables. In other words, the first loop is apple and the second loop is orange.

Execute `loop_playbook.yml`

`cd ~/working`{{execute}}

`ansible-playbook loop_playbook.yml`{{execute}}

```text
(omit)
TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [add a user] ************************************
changed: [node-1] => (item=apple)
changed: [node-1] => (item=orange)
changed: [node-1] => (item=pineapple)

(omit)
```

Let's see if the user really added. If the playbook is written correctly, the user should have been created in node-1.

`ansible node-1 -b -m shell -a 'cat /etc/passwd'`{{execute}}

```text
(omit)
apple:x:1001:1001::/home/apple:/bin/bash
orange:x:1002:1002::/home/orange:/bin/bash
pineapple:x:1003:1003::/home/pineapple:/bin/bash
```

> Note: `/etc/passwd` file contains user information on Linux.

Suppose you want to add more users of `mango', `peach'. In that case, how should I edit the playbook? Please edit the playbook and try again. If the execution results are as follows, it means the playbook is described correctly. You'll be able to see that the idempotent operation.

`ansible-playbook loop_playbook.yml`{{execute}}

```text
(omit))
TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [add a user] ************************************
ok: [node-1] => (item=apple)
ok: [node-1] => (item=orange)
ok: [node-1] => (item=pineapple)
changed: [node-1] => (item=mango)
changed: [node-1] => (item=peach)

(omit)
```

Examples of answers are provided at the end of this page.

> Note: In this exercise, the variable `user_list` is defined inside the playbook, but by placing it in a file such as `group_vars`, you can manage the operation of adding users separately from the data of adding users.

Although the simplest loops have been introduced here, [official documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html)shows how to loop in various cases. Please use it differently depending on the situation.


## Conditional expression
---
Ansible's conditional expressions are used to control whether a task is performed under certain conditions. Use the `when' clause in the description of the condition. A typical use is to perform or not perform the following tasks based on the results of a task.

Let's write the following `~/working/when_playbook.yml`.
```yaml
---
- name: start httpd if it's stopped
  hosts: node-1
  become: yes
  tasks:
    - name: install httpd
      yum:
        name: httpd
        state: latest

    - name: check httpd processes is running
      shell: ps -ef |grep http[d]
      register: ret
      ignore_errors: yes
      changed_when: no

    - name: print return value
      debug:
        var: ret

    - name: start httpd (httpd is stopped)
      service:
        name: httpd
        state: started
      when:
        - ret.rc == 1
```

This playbook checks the startup status of the httpd process and starts if it does not exist.

> Note: In fact, this process has the same effect as the `service' due to idempotency, so it is not meaningful, but please think of it as practice material.

- `register: ret` The results of `ps-ef|grep http[d]` are stored here.
- `ignore_errors: yes` The option to ignore errors that occur in the task. This command fails if a process is not found, so if you do not add this option, the task stops here.
- `changed_when: no` Describe the conditions under which this task becomes `changed`. Normally, the `shell` module always returns `changed`, but you can specify the conditions that will be `changed`.
  - Set `no' here always returns `ok'. This method is often used to execute commands that do not affect the OS (because commands that do not change anything return `changed`), as it only executes the `ps-ef` command this time.
- `when:` Write the conditions here in the list format. If multiple conditions are given as a list, it becomes an AND condition.
  - `- ret.rc == 1` is comparing the value of `rc` which is the return value of shell module. The return value of the command line is stored in `rc`. In other words, if the process cannot be found with `ps -ef | grep http[d]`, an error occurs and `1` is stored here.

Stop httpd before running the playbook.(This may be an error, but please ignore it.)

`ansible node-1 -b -m shell -a 'systemctl stop httpd'`{{execute}}

Execute `~/working/when_playbook.yml`

`ansible-playbook when_playbook.yml`{{execute}}

```text
TASK [check httpd processes is running] **************
fatal: [node-1]: FAILED! => {"changed": false, "cmd": "ps -ef |grep http[d]", "delta": "0:00:00.023918", "end": "2019-11-18 06:07:44.403881", "msg": "non-zero return code", "rc": 1, "start": "2019-11-18 06:07:44.379963", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
...ignoring

TASK [print return value] ****************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "cmd": "ps -ef |grep http[d]",
        "delta": "0:00:00.023918",
        "end": "2019-11-18 06:07:44.403881",
        "failed": true,
        "msg": "non-zero return code",
        "rc": 1,
        "start": "2019-11-18 06:07:44.379963",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "",
        "stdout_lines": []
    }
}

TASK [start httpd (httpd is stopped)] ****************
changed: [node-1]
```

Here, the httpd startup task is running because it meets the conditions of `ret.rc == 1`.

Now, run `~/working/when_playbook.yml` again. Now httpd is up status.

`ansible-playbook when_playbook.yml`{{execute}}

```text
TASK [check httpd processes is running] **************
ok: [node-1]

TASK [print return value] ****************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "cmd": "ps -ef |grep http[d]",
        "delta": "0:00:00.018448",
        "end": "2019-11-18 06:08:30.779933",
        "failed": false,
        "rc": 0,
        "start": "2019-11-18 06:08:30.761485",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "root      4913     1  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4914  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4915  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4916  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4917  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND\napache    4918  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
        "stdout_lines": [
            "root      4913     1  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4914  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4915  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4916  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4917  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND",
            "apache    4918  4913  0 06:07 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND"
        ]
    }
}

TASK [start httpd (httpd is stopped)] ****************
skipping: [node-1]
```

In this run, the value of `ret.rc` is `0`, so it does not match the condition and becomes `skipping`.

More information, such as how to describe the conditions, is provided in the [official document](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html).

You can use conditional expressions to control the processing according to the situation. However, if you specify too complex conditions, debugging and maintenance can be difficult. It is important to standardize the environment to prevent conditional branching as much as possible.

## Handler
---
Handlers are similar to conditional expressions such as `when` clauses, but have more limited uses. Specifically, when a specific task becomes `changed`, it starts another task. As a typical use, there may be cases where the process is restarted into a set when a setting file is updated.

In the exercise, you will distribute `httpd.conf` to the server and create a playbook that will restart `httpd` when the file is updated.

First, get the `httpd.conf` you want to distribute from the server.

`ansible node-1 -m fetch -a 'src=/etc/httpd/conf/httpd.conf dest=files/httpd.conf flat=yes'`{{execute}}

```text
node-1 | CHANGED => {
    "changed": true,
    "checksum": "fdb1090d44c1980958ec96d3e2066b9a73bfda32",
    "dest": "/notebooks/solutions/files/httpd.conf",
    "md5sum": "f5e7449c0f17bc856e86011cb5d152ba",
    "remote_checksum": "fdb1090d44c1980958ec96d3e2066b9a73bfda32",
    "remote_md5sum": null
}
```

`ls -l files/`{{execute}}

```text
total 16
-rw-r--r-- 1 jupyter jupyter 11753 Nov 18 07:40 httpd.conf
-rw-r--r-- 1 jupyter jupyter     2 Nov 17 14:35 index.html
```

- [`fetch`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html) module is a module that imports files from the remote server to local. (opposite to the `copy` module)

Edit `~/working/handler_playbook.yml` as follows:

```yaml
---
- name: restart httpd if httpd.conf is changed
  hosts: node-1
  become: yes
  tasks:
    - name: Copy Apache configuration file
      copy:
        src: files/httpd.conf
        dest: /etc/httpd/conf/
      notify:
        - restart_apache
  handlers:
    - name: restart_apache
      service:
        name: httpd
        state: restarted
```

The handler consists of `notify` and `handler`.

- Declare to send `notify` for the `notify:` handler, and specify the code that is actually sent after that.
  - `- restart_apache` It is specifying the code to be sent.
- `handlers:` declare the handler section and describe the processing corresponding to the code sent below.
  `- name: restart_apache`: Perform this task as a handler by defining the name corresponding to `restart_apache` in `notify`.

Execute `~/working/handler_playbook.yml`.

`ansible-playbook handler_playbook.yml`{{execute}}

```text
PLAY [restart httpd if httpd.conf is changed] ********

TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [Copy Apache configuration file] ****************
ok: [node-1]

PLAY RECAP *******************************************
node-1  : ok=2 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

In this state, all tasks are `ok`. This is because at this point, httpd.conf from the server is distributed directly to the server, so `changed` does not occur. Therefore, `handler` will not start in the current state.

> Note: This is because the idempotency of the copy module works. The file you tried to copy already exists and the contents are the same, so it is ok because you don't need to copy.

Then, edit `~/working/files/httpd.conf` and make the copy `changed`. Please edit the file as below.

```text
ServerAdmin root@localhost
      ↓
ServerAdmin centos@localhost
```

Run `~/working/handler_playbook.yml` again.

`ansible-playbook handler_playbook.yml`{{execute}}

```text
PLAY [restart httpd if httpd.conf is changed] ********

TASK [Gathering Facts] *******************************
ok: [node-1]

TASK [Copy Apache configuration file] ****************
changed: [node-1]

RUNNING HANDLER [restart_apache] *********************
changed: [node-1]

PLAY RECAP *******************************************
node-1 : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

Because of the update of `httpd.conf`, the 'copy' module became `changed`. Then the configured `notify` is called and `restart_apache` is running.

In this way, a method of executing another task with the trigger of `changed` of the task is a handler.


## Answers of exercises
---
- [loop\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/loop_playbook.yml)
- [when\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/when_playbook.yml)
- [handler\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/handler_playbook.yml)