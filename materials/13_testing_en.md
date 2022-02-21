# Test Automation, Report Generation
---
Ansible can also be used to automate testing and verification tasks. In particular, automating various verification tasks, such as large-scale tests and small but repetitive tests, can be very effective.

In this section, we will see how to create a playbook to run tests.

## Commonly used modules for testing
---
First, let's take a look at some modules that are often used in testing. Of course, there are many other modules that can be used to write automated tests.

- [shell](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html) module: Executes an arbitrary command and collects the results.
- [uri](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/uri_module.html) module: Issues an HTTP method to an arbitrary URL.
- \*\_command module: This module mainly issues arbitrary commands to network devices and collects the results.
- \*\_facts/info module: This module is primarily used to retrieve information about the environment.
- [assert](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/assert_module.html) module: Evaluates a conditional expression and returns ok if it is true.
- [fail](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fail_module.html) module: Evaluates a conditional expression and returns failed if it is true.
- [template](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html) module: Used to output the test results.
- [validate\_argument\_spec](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/validate_argument_spec_module.html) module: Used to validate role parameters.

> Note: When testing an environment that has been built or modified with Ansible using Ansible itself, it is recommended to use a different module than the one used to build it.  For example, you can use the `shell` module to check a file distributed using the `copy` module.


## How to write tests
---
A common pattern for testing with Ansible is to get information with `shell`, `*_command`, and `*_facts`, and then judge the result with `assert` and `fail`.

Sample
```yaml
- name: get command AAA result
  shell: exec AAA
  register: ret_AAA

- name: check AAA result
  assert:
    that:
      - ret_AAA.rc == 0
```

Normally, when playbook encounters an error, it will stop at the task that caused the error. This is not a problem for configuration, but for testing, the test will also stop in the middle. The test must run to the end whether an error occurs or not, and we need to be able to know how many of the total test items succeeded or failed. The test must run to the end whether an error occurs or not, and we need to be able to know how many of the total test items succeeded or failed.

Sample
```yaml
- ignore_errors: yes
  block:
  - name: get command AAA result
    shell: exec AAA
    register: ret_AAA

  - name: get command BBB result
    shell: exec BBB
    register: ret_BBB

  - name: get command CCC result
    shell: exec CCC
    register: ret_CCC

- name: check test results
  assert:
    that: "{{ item.failed == false }}"
  loop:
    - "{{ ret_AAA }}"
    - "{{ ret_BBB }}"
    - "{{ ret_CCC }}"
```

In the above sample, the results are judged in a batch loop. This method is convenient, but it is necessary to output information so that the `register` side can make decisions easily. If you want to set up complex conditions, you may need to write as follows.

```yaml
- name: check test results
  assert:
    that:
      - ret_AAA.rc == 0                     # Determine the return value
      - ret_BBB.stdout.find("string") != -1 # Output results contain string
      - ret_CCC.stdout.find("string") == -1 # Output results does not contain strings
```
In the `that` argument of `assert`, passing a condition as an array will be treated as an AND condition



## Create a test
---
Let's actually create a test. As a simple example, we will assume that we have a server with an httpd server installed and running. Specifically, we will test against a server that has run the following.

`ansible node-1 -b -m yum -a 'name=httpd state=present'`{{execute}}

`ansible node-1 -b -m systemd -a 'name=httpd state=started enabled=yes'`{{execute}}

To test the above, we will perform the following checks.

- Package httpd is installed
- Process httpd is present (running)
- The service httpd should be automatically started (enabled)

Edit the file `~/working/testing_assert_playbook.yml` as follows.

```yaml
---
- name: Test with assert
  hosts: node-1
  become: yes
  gather_facts: no
  tasks:
    - ignore_errors: yes
      block:
        - name: Is httpd package installed?
          shell: yum list installed | grep -e '^httpd\.'
          register: ret_httpd_pkg

        - name: check httpd processes is running
          shell: ps -ef |grep http[d]
          register: ret_httpd_proc

        - name: Is httpd service enabled?
          shell: systemctl is-enabled httpd
          register: ret_httpd_enabled

    - block:
        - name: Assert results
          assert:
            that:
              - ret_httpd_pkg.rc == 0
              - ret_httpd_proc.rc == 0
              - ret_httpd_enabled.rc == 0
```

- In the first `block`, we run the necessary test codes under `ignore_errors` and `register` the results of each.
- In the second `block`, we check the results with the `assert` module. Normally, the `block` here is unnecessary, but we will write it for the next exercise.

Execute the playbook

`cd ~/working`{{execute}}

`ansible-playbook testing_assert_playbook.yml`{{execute}}

This Playbook should finish successfully.

The next step is to generate an error in the test. We purposely stop httpd and then run the test.

`ansible node-1 -b -m systemd -a 'name=httpd state=stopped enabled=yes'`{{execute}}

`ansible-playbook testing_assert_playbook.yml`{{execute}}

This time the test should have failed, because httpd is not running, and the check with `assert` failed.


## Create a report of the test results.
---
The next step is to output the test results as a report. It is common to use the `template` module, but here we will use the `copy` module and the `jinja2` style notation to create a report.

Edit the previous file `~/working/testing_assert_playbook.yml` as follows. The following `always` will be the added part.

```yaml
---
- name: Test with assert
  hosts: node-1
  become: yes
  gather_facts: no
  tasks:
    - ignore_errors: yes
      block:
        - name: Is httpd package installed?
          shell: yum list installed | grep -e '^httpd\.'
          register: ret_httpd_pkg

        - name: check httpd processes is running
          shell: ps -ef |grep http[d]
          register: ret_httpd_proc

        - name: Is httpd service enabled?
          shell: systemctl is-enabled httpd
          register: ret_httpd_enabled

    - block:
        - name: Assert results
          assert:
            that:
              - ret_httpd_pkg.rc == 0
              - ret_httpd_proc.rc == 0
              - ret_httpd_enabled.rc == 0
      always:
        - name: build report
          copy:
            content: |
              # Test Reports
              ---
              | test | result |
              | ---- | ------ |
              {% for i in results %}
              | {{ i.cmd | regex_replace(query, '&#124;') }} | {{ i.rc }} |
              {% endfor %}
            dest: result_report_{{ inventory_hostname }}.md
          vars:
            results:
              - "{{ ret_httpd_pkg }}"
              - "{{ ret_httpd_proc }}"
              - "{{ ret_httpd_enabled }}"
            query: "\\|"
          delegate_to: localhost
```

- The added `always` will generate a report of the test results. This way, the report will be generated even if assert fails.
  - In this report, `Jinja2` is used directly in the `content` parameter of the `copy` module to create a file in `Markdown` format.
  - The `regex_replace` filter replaces a string with a regular expression.
    - Here, `|` in the command is replaced with `&#124;`. This is because `|` is a delimiter when outputting the results in table format, so the `|` in the command is replaced with another expression (`&#124;`).

Try to run the test with a successful pattern. Restart httpd for this.

`ansible node-1 -b -m systemd -a 'name=httpd state=started enabled=yes'`{{execute}}

`ansible-playbook testing_assert_playbook.yml`{{execute}}

This test should be successful. Check the contents of the report file `~/working/result_report_node-1.md` that should have been created (right click on the file to open it in Markdown preview mode).

Next, let's check the report by failing the test. Stop the httpd process and then run the test.

`ansible node-1 -b -m systemd -a 'name=httpd state=stopped enabled=yes'`{{execute}}

`ansible-playbook testing_assert_playbook.yml`{{execute}}

Check how the test reports have changed.

## Create configuration report
---
In the previous example, we have output the test results, but it is also possible to automatically generate configuration reports in the same way, and there are many examples of this being used in practice. In this section, we will try to generate a simple server configuration report.

Create the file `~/working/reporting_playbook.yml` as following.

```yaml
---
- name: Report with Ansible
  hosts: web
  gather_facts: true
  tasks:
  - name: build report
    copy:
      content: |
        # Server Configuration Reports: {{ inventory_hostname }}
        ---
        | name | value  |
        | ---- | ------ |
        {% for key, value in ansible_default_ipv4.items() %}
        | {{ key }} | {{ value }} |
        {% endfor %}
      dest: /tmp/setting_report_{{ inventory_hostname }}.md
    delegate_to: localhost
  
  - name: concatenate reports
    assemble:
      src: /tmp
      regexp: 'setting\_report\_*'
      dest: setting_report.md
      delimiter: "\n"
    run_once: true
    delegate_to: localhost
```

- `gather_facts: true` Let `setup` run before running the playbook so that we can take use the results.
- `{% for key, value in ansible_default_ipv4.items() %}` This time, we are retrieving settings related to the network.
  - To check the `ansible_default_ipv4` variable, run the following.
  - `ansible node-1 -m setup -a 'filter=ansible_default_ipv4'`{{execute}}
- `assemble` module: A module to combine files.
- `run_once: true` If this option is specified, only one host will be executed even if there are multiple hosts. This is because the join operation should be executed only once.

`cd ~/working`{{execute}}

`ansible-playbook reporting_playbook.yml`{{execute}}

When you run it, a file `setting_report.md` will be created in the working directory, and you can check the contents. (Please check it in Markdown preview mode)

The report output here can be converted from html format to pdf using [pandoc](https://pandoc.org/), so it can be submitted as a report if you make it look a little better.

A testing tool (framework) called [molecule](https://github.com/ansible-community/molecule) is also available for systematically executing tests like this one. In addition, molecule can be used to execute tests in a unified manner for high quality automation.

## Answers to the exercises
---
- [testing\_assert\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/materials/solutions/testing_assert_playbook.yml)
- [reporting\_playbook](https://github.com/irixjp/katacoda-scenarios/blob/materials/solutions/reporting_playbook.yml)
