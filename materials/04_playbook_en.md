# Writing and Executing Playbook
---
In the previous exercise, we used the Ad-Hoc command to execute the modules one by one, which is convenient in some situations, but in the actual work, we need to execute several steps in succession.However, when you are actually working on a project, you may need to execute several steps in succession, and executing the Ad-Hoc commands one after the other can be tedious. In the playbook, we describe the modules and parameters we want to call in order, and then execute them with `answer and load them into the `ansible-playbook` command to execute the contents of the playbook at once.

The first step in automating your infrastructure with Ansible is to create a playbook.

> Note: However, automation is not complete when you have a Playbook. It is true that the Playbook can replace procedures in the field, but it is only one part of the infrastructure work. To further automate and improve efficiency, it is also necessary to use automation as a means to provide services, to "reduce human coordination," and to automate "quality assurance tasks" through [infrastructure CI](https://www.shoeisha.co.jp/book/detail/9784798155128). Remember this and be careful never to make using Ansible or writing a playbook an end in itself.


## Playbook Basics
---
The `playbook` is written in [YAML](https://ja.wikipedia.org/wiki/YAML) format, and the important points about YAML are described below.

- YAML should be a text format for expressing data.
- Files should start with `---`.
- Indentation has meanings.
  - Indentation should be written in `space`. `tab` will result in an error.
- `key`: `value` makes it a dictionary format.
- Can be converted to and from [json](https://ja.wikipedia.org/wiki/JavaScript_Object_Notation)

Bellow is the playbook samples.
```yaml
---
- hosts: all
  become: yes
  tasks:
  - name: first task
    yum:
      name: httpd
      state: latest
  - name: second task
    service:
      name: httpd
      state: started
      enabled: yes
```

The playbook described in a json.

```json
[
	{
		"hosts": "all",
		"become": "yes",
		"tasks": [
			{
				"name": "first task",
				"yum": {
					"name": "httpd",
					"state": "latest"
				}
			},
			{
				"name": "second task",
				"service": {
					"name": "httpd",
					"state": "started",
					"enabled": "yes"
				}
			}
		]
	}
]
```

## Creating a playbook
---
Let's actually create a playbook.

Open the file `~/working/first_playbook.yml` with an editor. This file contains only `---` at the beginning. Follow the instructions below to add to this file and complete it as a playbook.

In this section, we will create a playbook to build a web server.

### play part
---
Please add the following to your file.

```yaml
---
- name: deploy httpd server
  hosts: all
  become: yes
```

The following is a description of what we have done here.
- `name:`: This is the name of the process to be performed in this playbook. It can be omitted. You can also write in Japanese.
- `hosts: all`: Specify the groups and nodes where the playbook will run. This must be a group or node that exists in the inventory you are using.
- `become: yes`: This declares that the playbook will elevate privileges to a privileged user at runtime, the same as `-b` used in the ansible command.

This part is called the `play` part of the playbook, and it defines the overall behavior of the playbook. Understand it as a kind of header for the entire playbook.Check the [Official documentation](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html#play) for details for the items that can be specified in the play part.

### task part
---
Next, add the following to the previous file to achieve the following state. Please pay attention to the indentation hierarchy.

```yaml
---
- name: deploy httpd server
  hosts: all
  become: yes
  tasks:
  - name: install httpd
    dnf:
      name: httpd
      state: latest

  - name: start & enabled httpd
    service:
      name: httpd
      state: started
      enabled: yes
```

The content added here is called the `task` part, and it describes the actual process to be performed by this playbook. In the `task` part, the modules are listed in the order in which they are to be invoked, and the necessary parameters are given to the modules.

- `tasks:` Defines that what follows is a task part.
- `- name: ...` A description of this task. Optional.
- `dnf:` `service:` Specifies the module to invoke.
- The following are the parameters given to the module.
  - `name: httpd` `state: latest`
  - `name: httpd` `state: started` `enabled: yes`

The modules that are invoked here are as follows.
- `dnf`: Used to install the httpd package.
- `service`: Used to start the installed httpd and enable the auto-start setting.

You can check the created playbook for syntax errors with the following command

`cd ~/working`{{execute}}

`ansible-playbook first_playbook.yml --syntax-check`{{execute}}

```text
playbook: first_playbook.yml
```

The above is the error-free case. If there is an error in indentation, etc., it will look like this.
```text
$ ansible-playbook first_playbook.yml --syntax-check

ERROR! Syntax Error while loading YAML.
  expected <block end>, but found '<block sequence start>'

The error appears to be in '/notebooks/working/first_playbook.yml': line 6, column 2, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:

  tasks:
 - name: install httpd
 ^ here
```

In this case, double-check that the indentation of the playbook is the same as in the sample.

## Execute the playbook
---
Let's execute the playbook that was created. Use the `ansible-playbook` command to run the playbook. If successful, the httpd server will start and you should be able to see the initial screen of apache.

`ansible-playbook first_playbook.yml`{{execute}}

```text
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node-2]
ok: [node-3]
ok: [node-1]

TASK [install httpd] ********************************************************
changed: [node-1]
changed: [node-2]
changed: [node-3]

TASK [start & enabled httpd] ************************************************
changed: [node-1]
changed: [node-2]
changed: [node-3]

PLAY RECAP ******************************************************************
node-1  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

If the output is as the above, access node-1,2,3 with a browser and see how the site works.

- [node-1]({{TRAFFIC_HOST1_8081}})
- [node-2]({{TRAFFIC_HOST1_8082}})
- [node-3]({{TRAFFIC_HOST1_8083}})

> Note: Please click on `node-1,2,3` at the above link. These will redirect you to port 80 for each node.

> Note: If you are doing the exercise on Jupyter, check `~/inventory_file` for the IP address you want to access, and use your browser to access the address shown in `http_access=http://35.73.128.87:8081`. This address will be redirected to port 80 of each node.

If you see a screen similar to the following, you have succeeded.

![apache_top_page.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/apache_top_page.png)


## Adding a task
---
Add a task to distribute the top page of the site to the playbook you have created.

Open `~/working/files/index.html` in the editor.

Edit the file as following
```html
<body>
<h1>Apache is running fine</h1>
</body>
```

In addition, edit `first_playbook.yml` as the following.
```yaml
---
- name: deploy httpd server
  hosts: all
  become: yes
  tasks:
  - name: install httpd
    dnf:
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
```

Once the editing is completed, let's run the playbook after performing the syntax check.


`ansible-playbook first_playbook.yml --syntax-check`{{execute}}

`ansible-playbook first_playbook.yml`{{execute}}

```text
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node-2]
ok: [node-3]
ok: [node-1]

TASK [install httpd] ********************************************************
ok: [node-1]
ok: [node-3]
ok: [node-2]

TASK [start & enabled httpd] ************************************************
ok: [node-2]
ok: [node-1]
ok: [node-3]

TASK [copy index.html] ******************************************************
changed: [node-1]
changed: [node-3]
changed: [node-2]

PLAY RECAP ******************************************************************
node-1  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

When the process is completed successfully, access the three nodes again with a browser. If the playbook was written correctly and works, you should see the contents of `index.html` that you just created.

## Idempotency
---
The advantage of using Ansible modules is that the amount of description can be greatly reduced, but there are other advantages as well. And that is `idempotency`.

In this exercise, we run `ansible-playbook first_playbook.yml` twice: when we install and start httpd, and when we add the top page of the site. In other words, the task of installing and starting httpd is executed twice. However, there is no error in the second playbook execution. This is because Ansible's `idempotency' is working.

If you carefully check the results of the first run and the second run, you will notice a difference in the output results. The difference is whether the output is `changed` or `ok` for each process.

- `changed`: Ansible ran the process and changed the state of the target host (Ansible actually configured it).
- `ok`: Ansible tried to do something, but it didn't change the state of the host because it was already configured as expected (Ansible didn't do the configuration or didn't need to do it).

This is the idempotency power of Ansible: it knows before it runs whether the process you are about to perform needs to be performed or not.

Now let's run the playbook again, and think about what the states of the three tasks will look like before we run it.

`ansible-playbook first_playbook.yml`{{execute}}

```text
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node-3]
ok: [node-1]
ok: [node-2]

TASK [install httpd] ********************************************************
ok: [node-2]
ok: [node-1]
ok: [node-3]

TASK [start & enabled httpd] ************************************************
ok: [node-1]
ok: [node-2]
ok: [node-3]

TASK [copy index.html] ******************************************************
ok: [node-3]
ok: [node-1]
ok: [node-2]

PLAY RECAP ******************************************************************
node-1  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

All tasks should now be `ok`, and you can easily see the difference in results by lining up the last `PLAY RECAP` part of the playbook execution. Here you can compare how many tasks have been `changed` on each node. Please compare how many tasks have been `changed` at each node.


First execution(two tasks has been changed)
```text
PLAY RECAP ******************************************************************
node-1  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

Second execution(one task has been changed)
```text
PLAY RECAP ******************************************************************
node-1  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

Third execution(no changes)
```text
PLAY RECAP ******************************************************************
node-1  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-2  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node-3  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

So what's so exciting about this idempotency?

- Playbook can be used to declaratively describe the state of the system, not the steps of the process -> Playbook = configuration parameters + procedures.
- Even if a process executed on multiple hosts fails in the middle, it can be restarted from the beginning (because the part of the configuration that succeeded is skipped (ok)).
- Consolidation of procedures. You will be able to cover various scenes such as initial configuration, adding nodes, etc. with only one Playbook.

> Note: The last part, "consolidate the steps", is particularly important. In the past, it would have been necessary to create each procedure separately depending on the situation, but by utilizing idempotency, it is possible to centralize and automate them. If you can make good use of idempotency, you can not only automate and improve efficiency, but also greatly improve the efficiency of the automation development itself.

Each module in Ansible is designed to take this idempotency into account, and by using this module, you can write automation easily and safely.

If this is the case with your own automation shell scripts, you can easily imagine the troublesome considerations such as whether or not to re-run the script from the beginning, especially in case of failure or redo (preparing another script or procedure to run it from the midpoint...).

> Note: However, not all modules in Ansible are guaranteed to be fully with idempotency. Some modules, such as shell, do not know what will be executed, and some modules may not be with idempotency in principle depending on the target of operation (NW devices or cloud environment).It is necessary for users to pay attention when using such modules.

## Answers to the Exercises
- [first\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/first_playbook.yml)
- [files/index.html](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/files/index.html)
