# Management and Reuse of Role(Galaxy)
---
In this section, we will look at how to manage and reuse the roles you have created. Roles make it possible to create parts of the playbook, but it is not advisable to copy a set of roles into the `roles` directory every time you want to reuse them. This is because it is not possible to keep up with changes to the original roles after copying. Also, the effort involved in trying to manage such a distribution of source code would be enormous.

To solve this problem, Ansible provides a way to get a set of roles needed to run a playbook in one place. That is the [ansible-galaxy](https://docs.ansible.com/ansible/latest/galaxy/user_guide.html) command.

This section will explain the use of Galaxy as well as the methods of Role management.

## How to manage Roles
---
Ansible strongly recommends the use of a source code control system such as `git` for managing roles.

> Note: Although I say recommended, it is practically a requirement. Of course, it is possible to manage Role and playbook files manually. However, it is only possible, and it should be strongly stated that "manual management should not be done" under any circumstances.

When managing roles with git, the basic rule is "1 role = 1 repository". If you use this management method, you will have a large number of repositories, so it is a good idea to create a catalog of roles. Ansible provides an official catalog mechanism called [Galaxy](https://galaxy.ansible.com/), where you can register your roles.

There are already a huge number of roles on Galaxy, and in most cases you can find what you want by searching.

> Note: In some cases it can be used as-is, and in others it needs to be modified, but it can save you a lot of time and effort in creating roles while checking whether there are any every time.

## Using the `ansible-galaxy` command
---
Let's import a role for the exercise and make use of it. Use the `ansible-galaxy` command to reuse a role that has already been created and is accessible on git.

The roles we will use are the following.

- [irixjp.role\_example\_hello](https://galaxy.ansible.com/irixjp/role_example_hello) Roles that only display greetings
- [irixjp.role\_example\_uptime](https://galaxy.ansible.com/irixjp/role_example_uptime) Roles that only display uptime results

> Note: To create a role for `Galaxy`, simply add [`meta`](https://galaxy.ansible.com/docs/contributing/creating_role.html) data to the normal role and register it with Galaxy.

To get all these roles at once, prepare a `requirements.yml` file.

Edit the file `~/working/roles/requirements.yml` as follows.

```yaml
---
- src: irixjp.role_example_hello
- src: irixjp.role_example_uptime
```

The format of the `requirements.yml` is described in detail in [here](https://galaxy.ansible.com/docs/using/installing.html). Here, we specify the name of the catalog on Galaxy (`irixjp.role_example_hello`), but you can also refer to github or your own git server directly.

Next, create a `~/working/galaxy_playbook.yml` that uses this role.
```yaml
---
- name: using galaxy
  hosts: node-1
  tasks:
    - import_role:
        name: irixjp.role_example_hello

    - import_role:
        name: irixjp.role_example_uptime
```

You are now ready to go.

## Download the Role and run the playbook
---
Get the role from Galaxy.

`cd ~/working`{{execute}}

`ansible-galaxy role install -r roles/requirements.yml`{{execute}}

```text
- downloading role 'role_example_hello', owned by irixjp
- downloading role from https://github.com/irixjp/ansible-role-sample-hello/archive/master.tar.gz
- extracting irixjp.role_example_hello to /jupyter/.ansible/roles/irixjp.role_example_hello
- irixjp.role_example_hello (master) was installed successfully
- downloading role 'role_example_uptime', owned by irixjp
- downloading role from https://github.com/irixjp/ansible-role-sample-uptime/archive/master.tar.gz
- extracting irixjp.role_example_uptime to /jupyter/.ansible/roles/irixjp.role_example_uptime
- irixjp.role_example_uptime (master) was installed successfully
```

The `ansible-galaxy install` command will deploy roles to `$HOME/.ansible/roles` by default. This can be controlled with the `-p` option.

You can also use `-f` to overwrite existing downloaded roles and learn them, so you will always have the latest roles available.

To check the downloaded roles, execute the following command.

`ansible-galaxy role list`{{execute}}

```text
# /root/.ansible/roles
- irixjp.role_example_uptime, master
- irixjp.role_example_hello, master
```

Let's execute the plabook.

`ansible-playbook galaxy_playbook.yml`{{execute}}

```text
TASK [irixjp.role_example_hello : say hello!] ********
ok: [node-1] => {
    "msg": "Hello"
}

TASK [irixjp.role_example_uptime : get uptime] *******
changed: [node-1]

TASK [irixjp.role_example_uptime : debug] ************
ok: [node-1] => {
    "msg": " 07:41:00 up 1 day,  3:04,  1 user,  load average: 0.00, 0.01, 0.05"
}
```

This way, roles can be managed on Galaxy or git, and the roles required by Playbook can be managed in `requirements.yml` to reduce source code distribution and increase efficiency and safety.

## Using custom modules and custom filters in Roles
---
Custom modules and filters contained in a Role can be used by tasks outside the Role once the Role is loaded into the playbook.

As an example, the role `irixjp.role_example_hello` contains the custom module `sample_get_locale`.

This custom module can be used as follows. Edit `~/working/galaxy_playbook.yml`.
```yaml
---
- name: using galaxy
  hosts: node-1
  tasks:
    - import_role:
        name: irixjp.role_example_hello

    - import_role:
        name: irixjp.role_example_uptime

    - name: get locale
      sample_get_locale:
      register: ret

    - debug: var=ret
```

Now let's execute it.

`ansible-playbook galaxy_playbook.yml`{{execute}}

```text
(snip)
TASK [get locale] *********************
ok: [node-1]

TASK [debug] **************************
ok: [node-1] => {
    "ret": {
        "changed": false,
        "failed": false,
        "locale": "en_US.UTF-8"
    }
}
```

You can see that the custom module is able to run after the role.

In this way, roles can be used as a mechanism for distributing custom modules. In this case, leave the `tasks/main.yml` of the role empty, and implement the role itself as not executing any tasks.


## How to create a role for Galaxy
---
In order to create redistributable roles using Galaxy, you need to include `galaxy.yml` in your repository. See [Creating Roles](https://galaxy.ansible.com/docs/contributing/creating_role.html) for instructions.


## Supplemental Information
---
Although you need to run `ansible-galaxy role install` every time on the command line, Ansible Automation Platform and /AWX have a feature to automatically download roles from `requirements.yml` before running the playbook. This can systematically prevent accidents such as forgetting to update the role.


## Answers to the exercises
---
- [galaxy\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/galaxy_playbook.yml)
- [requirements.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/roles/requirements.yml)
