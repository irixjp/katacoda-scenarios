# Coding Conventions
---
Ansible has a high degree of freedom in coding and can write playbooks in a variety of ways. However, there are cases where this degree of freedom can cause problems. That's happens when the team proceeds automation.

When an individual creates a playbook at will, some people add `name` to the task, but others do not.As such, when there is an imbalance in content for each individual, the cost of ensuring quality increases.

Therefore, the team needs coding conventions. By creating rules, teams can write a code in common, leading to equalization of skills and lower review costs. However, on the other hand, it is also necessary to check whether it complies with the terms and conditions.

Therefore, Ansible provides a way to automatically verify compliance with the terms and conditions, so we will learn how to use them.

## Ansible Lint
---
Ansible offers a program called [ansible-lint](https://github.com/ansible/ansible-lint). This can be done by a static analysis of playbook to check if there is any violations the rules. By default, the rules you check are commonly used, and you can define your own rules.

We are preparing the following 2 playbooks as samples.

- `~/working/lint_ok_playbook.yml`
- `~/working/lint_ng_playbook.yml`

Both of these playbooks can run correctly and print the output `ps-ef`. Please do two things as a test.

`cd ~/working`{{execute}}

`ansible-playbook lint_ok_playbook.yml`{{execute}}

`ansible-playbook lint_ng_playbook.yml`{{execute}}

Both should have been successful. Now, let's apply `ansible-lint` to these 2 playbooks.

`ansible-lint lint_ok_playbook.yml`{{execute}}

This will be end normally.

> Note: Warning may appear, but please ignore it.

`ansible-lint lint_ng_playbook.yml`{{execute}}

Example Error 1
```text
yaml: truthy value should be one of [false, true] (truthy)
lint_ng_playbook.yml:3
```

Example Error 2
```text
unnamed-task: All tasks should be named
lint_ng_playbook.yml:5 Task/Handler: shell  set -o pipefail
ps -ef |grep -v grep
```

The second command should have an error as example. There should also be other errors.

> Note: This is because there is a slight difference in the check for each version of the Lint. Basically, newer versions tend to be more stringent.

One of the errors is `All tasks should be named', which shows that all tasks violate the terms and conditions of 'need to keep their names'.

Let's see which rules `ansible-lint` checks by default.Execute the following command:

`ansible-lint -L`{{execute}}

You can see that a number of conventions are defined by default. These terms and conditions are tagged so that you can specify tags to apply and exclude them altogether.

To confirm the tag list, execute the following:

`ansible-lint -T`{{execute}}

You can exclude the tag you want to exclude by using the `-x` option. Run the line exclude for the rule so that 'lint_ng_playbook.yml' becomes OK as a test. Check the error, check the tag of the rule which are violating and specify it following `-x`.

> Note: `-x` can be used multiple times in a single command. For example `ansible-lint -x unnamed-task -x yaml`

Next, modify the playbook so that `lint_ng_playbook.yml' does not fail without using rule exclusion. When modified, run the following to check the results.

`ansible-lint lint_ng_playbook.yml`{{execute}}

## Define non-standard rules
---
In addition to standard checks, you can define rules specific to projects and organizations.

Custom rules are defined in python, and rules can be easily created by inheriting a class called `AnsibleLintRule`.

For more information, please check this [sample](https://github.com/ansible/ansible-lint/blob/master/examples/rules/task_has_tag.py).

The following will be defined in the independent rules.

- Prevent prohibited operations (commands) from entering the playbook
  - For example, if you have a bug in your router's firm and you want to prohibit a command that causes the switch to hang when you execute the command.
  - Risky commands that can cause problems with other commands.


## Additional Check Tools
---
A more general LINT tool, [YAMLLint](https://github.com/adrienverge/yamllint), is available to check variable naming conventions and wording for `name1. Use it as needed.

## Answer to exercises
---
- [lint\_ok\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/working/lint_ok_playbook.yml)
- [lint\_ng\_playbook.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/materials/working/lint_ng_playbook.yml)
