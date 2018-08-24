test

## Issue 1

Indents are something wrong.
```yaml
---
- name: test palybook
  hosts: test
  tasks:
    - test
      test1
    - test
      test2
```

Above code's original is here.

https://github.com/irixjp/katacoda-scenarios/blob/master/sandbox/step0.md


## Issue 2

This course has "courseData" script below.
https://github.com/irixjp/katacoda-scenarios/blob/master/sandbox/env-init.sh

But I can't find the evidence that the script worked.

`find / | grep test.txt`{{execute}}


## Issue 3

This course has a editor and a terminal.

When I put a file from terminal,

`touch some.txt`{{execute}}

I can't find the file in editor.


Thanks!
