# Componentization by Role
---
So far, we have listed modules directly on the playbook. The automation using Ansible is possible in this way, but when you actually use Ansible, you often want to reuse previous operations. Copying and pasting previous codes at that time is not efficient, but when you call the entire other playbook, most of them do not work well because the group name written in `hosts:` and the inventory do not match. What appears there is the idea of `Role` in the following picture.

![structure.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/structure.png)

Automation can be partized in various units of work to make reusable parts. `Role` is completely separated from the inventory and can be called and used in various playbooks. This method of developing and managing playbooks is called [best practice](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html) in Ansible.


> Note: A module is a component of the tasks that occur frequently in the infrastructure, but a role is a component that summarizes the steps that occur frequently in your organization or project.

## Role Structure
`Role` places files in the directory in a predetermined configuration. Then, the directory can be called from Ansible as `Role`.

The representative role structure is listed below.

```text
site.yml        # Invoking playbook
roles/          # Ansible determines that the Role is stored in the Role directory
                # of the same layer as the Playbook.     
  your_role/    # A directory that stores a role called your_role.
                # (Directory name = role name)
    tasks/      #
      main.yml  #  Describe the tasks you want to perform in the role.
    handlers/   #
      main.yml  #  ロールの中で使用するハンドラーを記述します。
    templates/  #
      ntp.conf.j2  # Describe the handler used in the role.
    files/      #
      bar.txt   #  Place the files to be used in the role.
      foo.sh    #
    defaults/   #
      main.yml  #  List the variables and default values used in the role.
  your_2nd_role/   # The role is called your_2nd_role.
```

When creating a directory structure as described above, `site.yml` can call roles as follows:

```yaml
---
- hosts: all
  tasks:
  - import_role:
      name: your_role

  - include_role:
      name: your_2nd_role
```

In this way, processing can be called simply by specifying the name of the role using a module called `import_role`, `input_role`.Both modules call roles, and the differences are as follows.

- [`import_role`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/import_role_module.html) Load roles before running playbook（pre-read）
- [`include_role`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_role_module.html) Roles are loaded when performing tasks (post-read)

> Note: You don't have to be aware of the distinction between the two at this time. Basically, using `import_role` is safer and simpler.`include_role` is used to describe complex operations, such as dynamically changing the role called by operation.

The procedure part is partized as Role and managed separately from the automation object, and Playbook manages which role to apply sequentially to which host group.

## Create Role
---
It's not difficult to actually write a roll. It's just dividing the processing you've written so far into a set directory.

In this exercise, we create a `web_setup` role to set up a web server. It becomes the following directory structure.

```text
role_playbook.yml     # Playbook that actually calls the role
roles
└── web_setup              # Role name
    ├── defaults
    │   └── main.yml       # Store default values of variables
    ├── files
    │   └── httpd.conf     # Store files to be distributed
    ├── handlers
    │   └── main.yml       # Define handler
    ├── tasks
    │   └── main.yml       # Describe task
    └── templates
        └── index.html.j2  # Place template files
```

Create each file.

### Create Task File

Edit `~/working/roles/web_setup/tasks/main.yml`

```yaml
---
- name: install httpd
  yum:
    name: httpd
    state: latest

- name: start & enabled httpd
  service:
    name: httpd
    state: started
    enabled: yes

- name: Put index.html from template
  template:
    src: index.html.j2
    dest: /var/www/html/index.html

- name: Copy Apache configuration file
  copy:
    src: httpd.conf
    dest: /etc/httpd/conf/
  notify:
    - restart_apache
```

Place only the tasks you want to perform in the `tasks` directory.
Also, there is no need to write the `play` part in the role, so we will list only the tasks. The `templates`, `files` directory in the role can be referenced only by the file name in the module without explicitly specifying a path. For this reason, only the file name is described in `src` of the `copy` and `template` modules.


### Create handler file

Edit `~/working/roles/web_setup/handlers/main.yml`

```yaml
---
- name: restart_apache
  service:
    name: httpd
    state: restarted
```

Place only the processing you want to call as a handler in the `handlers` directory.

### Create Default Variables

Edit `~/working/roles/web_setup/defaults/main.yml`

```yaml
---
LANG: JP
```

In `defaults`, place the default value of the variable to be used within this Role. The Role default variable has a low overwrite priority, so you can overwrite and run it on the called Playbook side.
Also, be careful not to duplicate variable names because this variable can be referenced from the entire Playbook when Role is called.

> Note: In general, variable names used in Role are often given Role names as prefixes.

### Edit template file

Edit `~/working/roles/web_setup/templates/index.html.j2`

```jinja2
<html><body>
<h1>This server is running on {{ inventory_hostname }}.</h1>

{% if LANG == "JP" %}
     Konnichiwa!
{% else %}
     Hello!
{% endif %}
</body></html>
```

In `templates`, place the template file used by the `template` module. Files placed here will be accessible only by file name from a specific module called in Role.

### Create distribution file

Edit `~/working/roles/web_setup/files/httpd.conf` 

This file is retrieved from the server side. Please edit the file after executing the command as follows to retrieve the file.

`cd ~/working/roles/web_setup`{{execute}}

`ansible node-1 -b -m yum -a 'name=httpd state=latest'`{{execute}}

`ansible node-1 -m fetch -a 'src=/etc/httpd/conf/httpd.conf dest=files/httpd.conf flat=yes'`{{execute}}

Verify that the file has been retrieved.

`ls -l files/`{{execute}}

Edit the contents of the file.Depending on how the exercise progresses, it may have already been edited, so please leave it as it is.

```
ServerAdmin root@localhost
      ↓
ServerAdmin centos_role@localhost
```

In `files`, place files that Role uses for distribution, etc. This directory is also accessible only by filename from within Role to specific modules.


### Create playbook

Edit `~/working/role_playbook.yml`

Create a playbook that actually calls the role.

```yaml
---
- name: using role
  hosts: web
  become: yes
  tasks:
    - import_role:
        name: web_setup
```

### Review all

Verify the role you created.

`cd ~/working`{{execute}}

`tree roles`{{execute}}

The necessary files are ready if they are structured as follows.

```text
roles
└── web_setup
    ├── defaults
    │   └── main.yml
    ├── files
    │   ├── dummy_file  # ここは無視してください。
    │   └── httpd.conf
    ├── handlers
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    └── templates
        └── index.html.j2
```

## Executing
---
Run the created playbook.

`ansible-playbook role_playbook.yml`{{execute}}

```text
(Omit)
TASK [web_setup : install httpd] *********************
ok: [node-1]
ok: [node-3]
ok: [node-2]

TASK [web_setup : start & enabled httpd] *************
ok: [node-1]
ok: [node-3]
ok: [node-2]

TASK [web_setup : Put index.html from template] ******
ok: [node-3]
ok: [node-2]
ok: [node-1]

TASK [web_setup : Copy Apache configuration file] ****
changed: [node-3]
changed: [node-2]
changed: [node-1]

RUNNING HANDLER [web_setup : restart_apache] *********
changed: [node-2]
changed: [node-3]
changed: [node-1]
(Omit)
```

After successful execution, access node-1,2,3 with a browser and see how the site works.

- [node-1]({{TRAFFIC_HOST1_8081}})
- [node-2]({{TRAFFIC_HOST1_8082}})
- [node-3]({{TRAFFIC_HOST1_8083}})

> Note: Please click on `node-1,2,3` at the above link. These will redirect you to port 80 for each node.

> Note: If you are doing the exercise on Jupyter, check `~/inventory_file` for the IP address you want to access, and use your browser to access the address shown in `http_access=http://35.73.128.87:8081`. This address will be redirected to port 80 of each node.

The use of roles dramatically improves automation reuse. This is because tasks and inventory are completely separate.
However, if you proceed with Role and Playbook at will, your description style will be shattered and management will be difficult.

Therefore, by establishing a certain rule called [best practice](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html), the outlook for where and what is defined will be improved, and other members will be able to reuse the role with confidence.

## Answers to exercises
---
- [role\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/role_playbook.yml)
- [web\_setup](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/roles/web_setup)
