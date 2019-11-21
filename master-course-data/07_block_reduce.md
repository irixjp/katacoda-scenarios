# エラーハンドリング
---
playbook で一連のタスクをグループ化してまとめて `when` や `ingore_errors` を適用することができます。ここで登場するのが `block` 句です。また `block` 句にはエラーハンドリングの機能もあり、`block` 内でのエラー に対して `rescue` 句のタスクを実行する、エラーに関係なく実行する `always` 句が使えます。

## block
---
`block` 句を用いた playbook は以下のように記述できます。

`working/block_playbook.yml` を編集してください。
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

        - name: Copy Apache configuration file
          copy:
            src: files/httpd.conf
            dest: /etc/httpd/conf/

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
        - ansible_facts['distribution'] == 'CentOS'
```




## rescue, always
---
