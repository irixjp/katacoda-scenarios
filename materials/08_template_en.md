# Template and Filter
---
Ansible has a template feature that allows dynamic file creation. We are using [`jinja2`](https://palletsprojects.com/p/jinja/) as the template engine.

Templates are a very versatile feature and can be used in a variety of situations. It is possible to dynamically generate and distribute configuration files for applications, and to create reports based on the information collected from each node.

## Jinja2 
---
To use a template, two elements are required.

- template file: a file with an embedded jinja2-style representation, typically with the j2 extension appended.
- [`template`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html) module: similar to the copy module. If the template file is specified in src and the destination is specified in dest, when the template file is copied, the jinja2 part is processed before copying the file.

Let's create the actual template.

Please create a file `~/working/templates/index.html.j2` and edit its contents to be as follows. This file will be the `jinja2` template file.

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

At first glance, this file looks like a simple HTML file, but there are parts enclosed in `{{ }}` and `{% %}`. These parts correspond to the `Jinja2` expressions that are expanded by the template engine.

- Evaluate the variables in `{{ }}` and embed the values in the brackets.
- Control statements can be embedded in `{% %}`.

Before the detailed explanation, let's first create `~/working/template_playbook.yml` and try to run the template. Please edit `template_playbook.yml` as follows.

```yaml
---
- name: using template
  hosts: web
  become: yes
  tasks:
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
        src: templates/index.html.j2
        dest: /var/www/html/index.html
```

- `template:` template module is called

Now let's try to run this playbook.

`cd ~/working`{{execute}}

`ansible-playbook template_playbook.yml -e 'LANG=JP'`{{execute}}

```text
(snip)
TASK [Put index.html from template] **********************
changed: [node-2]
changed: [node-3]
changed: [node-1]
(snip)
```

Let's confirm what the result is. Please run the following command.

`ansible web -m uri -a 'url=http://localhost/ return_content=yes'`{{execute}}

This command uses the [`uri`](https://docs.ansible.com/ansible/latest/modules/uri_module.html)  module, a module that issues HTTP requests.  This module is used to access `http://localhost/` from each node to retrieve the content.

```text
node-1 | SUCCESS => {
    (snip)
    "content": "<html><body>\n<h1>This server is running on node-1.</h1>\n\n<p>\n     Konnichiwa!\n</p>\n</body></html>\n",
    (snip)
    "url": "http://localhost/"
}
node-2 | SUCCESS => {
    (snip)
    "content": "<html><body>\n<h1>This server is running on node-2.</h1>\n\n<p>\n     Konnichiwa!\n</p>\n</body></html>\n",
    (snip)
    "status": 200,
    "url": "http://localhost/"
}
node-3 | SUCCESS => {
    (snip)
    "content": "<html><body>\n<h1>This server is running on node-3.</h1>\n\n<p>\n     Konnichiwa!\n</p>\n</body></html>\n",
    (snip)
    "status": 200,
    "url": "http://localhost/"
}
```

The `content` key contains the content of the retrieved `index.html`. Checking this content, we can see that the `{{ inventory_hostname }}` part in the template file is replaced with the hostname, and the `{% if LANG == "JP" %}` part is "Konnichiwa!

Now, let's change the condition and confirm what happens if `LANG == "JP"` is not valid.

`ansible-playbook template_playbook.yml -e 'LANG=EN'`{{execute}}

`ansible web -m uri -a 'url=http://localhost/ return_content=yes'`{{execute}}

In the next execution, you should see that "Hello!

> Note: You can also check to access each node in your browser.

By using templates in this way, it is possible to generate files dynamically. This feature has a very wide range of applications and can be used in various situations such as automatic generation of configuration files and configuration reports.


## Filter
---
One of the features of Jinja2 is [`filter`](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html). This can be used to expand variables with `{{ }}`, and allows for simple processing of variable values. This feature is also available in the playbook.

To use a filter, use the format `{{ var_name | filter_name }}`. Let's check some examples.


### default filter

This is a filter that sets the default value of a variable if it does not set any value.

`ansible node-1 -m debug -a 'msg={{ hoge | default("abc") }}'`{{execute}}

```text
node-1 | SUCCESS => {
    "msg": "abc"
}
```

### upper/lower filter

This filter converts strings to uppercase/lowercase.

`ansible node-1 -e 'str=abc' -m debug -a 'msg="{{ str | upper }}"'`{{execute}}

```text
node-1 | SUCCESS => {
    "msg": "ABC"
}
```

### min/max filter

This filter extract the minimum and maximum values from a list.

`ansible node-1 -m debug -a 'msg="{{ [5, 1, 10] | min }}"'`{{execute}}

```text
node-1 | SUCCESS => {
    "msg": "1"
}
```

`ansible node-1 -m debug -a 'msg="{{ [5, 1, 10] | max }}"'`{{execute}}

```text
node-1 | SUCCESS => {
    "msg": "10"
}
```

There are many other filters implemented, so you can use them according to your situation to make it easier to create a playbook.

## Answers to the Exercises
---
- [template\_html\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/block_playbook.yml)
- [files/index.html.j2](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/solutions/templates/index.html.j2)
