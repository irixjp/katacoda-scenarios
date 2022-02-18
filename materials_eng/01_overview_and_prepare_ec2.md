# Overview of the Exercise and Preparation of the Environment
---
This section provides an overview of the exercise environment and prepares the exercise environment.

## About the Exercise Environment
---
This exercise will be performed in an environment built on AWS.The exercise environment consists of the following:

![environment.png](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/kata_env.png)


## How to use the exercise environment
---
Follow the instructor to access the exercise environment.

### Start Terminal
---
Start the terminal on the JupyterLab. Click the folder icon on the left side of the screen to launch the file browser. If it is already started, leave it as it is.

![open_file_browser](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/open_file_browser.png)

Click the "+" button on the file browser to launch the launcher.

![add_launcher](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/add_launcher.png)

Click the Terminal icon from "Other" in the launcher.

![open_terminal](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/open_terminal.png)

After starting the terminal, check the operation. Run the following command at the terminal:

> Note: In this exercise, the part marked `{{execute}}` is the command to be executed in the exercise. You do not need to enter it yourself.

`ansible --version`{{execute}}

```text
ansible [core 2.11.5] 
  config file = /jupyter/.ansible.cfg
  configured module search path = ['/jupyter/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.8/site-packages/ansible
  ansible collection location = /jupyter/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.8.6 (default, Jan 29 2021, 17:38:16) [GCC 8.4.1 20200928 (Red Hat 8.4.1-1)]
  jinja version = 3.0.2
  libyaml = True
```

`ansible all -m ping -o`{{execute}}

```text
node-1 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/libexec/platform-python"},"changed": false,"ping": "pong"}
node-2 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/libexec/platform-python"},"changed": false,"ping": "pong"}
node-3 | SUCCESS => {"ansible_facts": {"discovered_interpreter_python": "/usr/libexec/platform-python"},"changed": false,"ping": "pong"}
```

> Note: 表示されるバージョン等の差異については無視してください。コマンドがエラーにならなければ演習が可能な状態になっています。
> Note: Ignore differences in displayed versions, etc. If the command does not fail, the exercise is ready.


You can change the display position by dragging and moving the tab after starting the terminal. You can also view it side by side with Markdown, as shown in the example below, so please change the placement to facilitate the exercise.

![vertical_split_terminal](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/vertical_split_terminal.png)


### Additional Information
---
If you are editing a file in this exercise environment, you can start the editor by opening the file from the file browser on the left (you can also use vi in the terminal).

一Some file formats (.md or .html) are previewed when double-clicked from the file browser. If you want to edit the file, select Editor from Right Click → Open with.