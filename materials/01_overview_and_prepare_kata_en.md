Let's prepare the exercise environment.

The VSCode editor will be displayed in the upper right corner of the screen. It may take some time to display.

## Preparation Work
---
Prepare the exercise environment by running the following command. This should take about 1-2 minutes (the command will automatically be copied to the terminal and executed when you click on it).

`apt install -y python3-pip && mkdir -p /opt/kata-materials && cd /opt/kata-materials && git clone --depth 1 https://github.com/irixjp/katacoda-scenarios.git . && pip install virtualenv && virtualenv ansible && source /opt/kata-materials/ansible/bin/activate && cd tools && bash ./kata_setup.sh && cd ~/`{{execute}}

> Note: The Ansible environment for the exercise will be built in a virtualenv.

## Environment Overview
---
In this exercise, we will use an environment built as follows. Three servers, `node-1`, `node-2`, and `node-3`, are running, and we will use Ansible to perform various automated operations on them.

![image0-1](https://raw.githubusercontent.com/irixjp/katacoda-scenarios/master/materials/images/kata_env.png "kata_env.png")

> Note: These server instances will be started as containers.
