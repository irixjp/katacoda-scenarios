# Blocks and Error Handling
---
You can group a set of tasks in a playbook and apply `when` and `ingore_errors` to them together. This is where `block` comes in. `block` also has an error handling feature that allows you to use `rescue` for errors within a `block` or `always` to run regardless of errors.

## block
---
A playbook using `block` can be written as the following.

Edit the `~/working/block_playbook.yml`
```yaml
---
- name: using block statement
  hosts: node-1
  become: yes
  tasks:
    - name: Install, configure, and start Apache
      block:
        - name: install httpd
          yum:
            name: httpd
            state: latest

        - name: start & enabled httpd
          service:
            name: httpd
            state: started
            enabled: yes

        - name: copy index.html
          copy:
            src: files/index.html
            dest: /var/www/html/
      when:
        - exec_block == 'yes'
```

- `block: ~~ when:` Here, three tasks are grouped together with a `block`, and a condition is added with a `when`. The `block` part is executed together when `exec_block == 'yes'` is fulfilled.

Let's see what the difference is in the results of running `block_playbook.yml` with `-e 'exec_block=no'` and `yes`.

`cd ~/working`{{execute}}

The first case is when the condition is not fulfilled.

`ansible-playbook block_playbook.yml -e 'exec_block=no'`{{execute}}

```text
TASK [install httpd] *********************************
skipping: [node-1]

TASK [start & enabled httpd] *************************
skipping: [node-1]

TASK [copy index.html] *******************************
skipping: [node-1]
```

You can see that the three tasks are skipped together. Next is the case where the condition is fulfilled.

`ansible-playbook block_playbook.yml -e 'exec_block=yes'`{{execute}}

```text
TASK [install httpd] *********************************
ok: [node-1]

TASK [start & enabled httpd] *************************
ok: [node-1]

TASK [copy index.html] *******************************
ok: [node-1]
```

You can see that there are three tasks running, grouped by `block`.

In this way, related tasks can be grouped together and controlled together using `when` and so on.

The keywords that can be used for `block` are listed in [Playbook Keywords](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html#block).


## rescue, always
---
`block` will allow you to use `rescue` and `always`.

Create `~/working/rescue_playbook.yml` as follows.

```yaml
---
- name: using block, rescue, always statement
  hosts: node-1
  become: yes
  tasks:
    - block:
        - name: block task
          debug:
            msg: "message from block"

        - name: check error flag in block
          assert:
            that:
              - error_flag == 'no'

      rescue:
        - name: rescue task
          debug:
            msg: "message from rescue"

        - name: check error flag in rescue
          assert:
            that:
              - error_flag == 'no'

      always:
        - name: always task
          debug:
            msg: "message from always"
```

- `block`: Describes the main processing.
  - `assert`: The module for checking. If the condition given by `that` is fulfilled, it will be `ok`, if not, it will be `failed`.
- `rescue`: Run if an error occurs inside a `block`.
- `always`: Always execute the process you want to execute.

This playbook will exit normally if the value of the `error_flag` variable is `no`, otherwise it will fail.

Let's run it to check the result. First, set `error_flag=no` to exit normally.

`ansible-playbook rescue_playbook.yml -e 'error_flag=no'`{{execute}}

```text
TASK [block task] ************************************
ok: [node-1] => {
    "msg": "message from block"
}

TASK [check error flag in block] *********************
ok: [node-1] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [always task] ***********************************
ok: [node-1] => {
    "msg": "message from always"
}
```

In this case, the task in `block` is executed, and then the task in `always` is executed.

Next, let's check the case when an error occurs.

`ansible-playbook rescue_playbook.yml -e 'error_flag=yes'`{{execute}}

```text
TASK [block task] ************************************
ok: [node-1] => {
    "msg": "message from block"
}

TASK [check error flag in block] *********************
fatal: [node-1]: FAILED! => {
    "assertion": "error_flag == 'no'",
    "changed": false,
    "evaluated_to": false,
    "msg": "Assertion failed"
}

TASK [rescue task] ***********************************
ok: [node-1] => {
    "msg": "message from rescue"
}

TASK [check error flag in rescue] ********************
fatal: [node-1]: FAILED! => {
    "assertion": "error_flag == 'no'",
    "changed": false,
    "evaluated_to": false,
    "msg": "Assertion failed"
}

TASK [always task] ***********************************
ok: [node-1] => {
    "msg": "message from always"
}
```

Here, the `block` task is executed first, but an error occurs. Because of the error, the `rescue` process is invoked. In addition, an error occurs in `rescue`, but the playbook is not stopped and `always` is executed.

As you can see, using `block`, `rescue`, and `always` makes it possible to handle errors in the playbook. A typical usage scenario is to use `rescue` to recover from failures and `always` to notify the status.

## Answers to the exercises
---
- [block\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/block_playbook.yml)
- [rescue\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/rescue_playbook.yml)
