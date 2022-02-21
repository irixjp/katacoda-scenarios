# Exercises
---
Please perform the following exercise.

Since httpd has been configured on each server in the exercise, please execute the following command to clear the environment. You can also use this command to clear the environment in the middle of the exercise.

`cd ~/working`{{execute}}

`ansible web -b -m yum -a 'name=httpd state=absent'`{{execute}}

`ansible web -b -m file -a 'path=/var/www/html/index.html state=absent'`{{execute}}

`ansible web -b -m yum -a 'name=epel-release state=absent'`{{execute}}

`ansible web -b -m yum -a 'name=nginx state=absent'`{{execute}}


## Question 1
---
Please create a role `httpd_myip` with the following functions.

- The directory for the role should be placed in `~/working/roles/httpd_myip`.
- This role will install httpd and make it ready to start.
- Place index.html on the top page, and configure this page to display the IP address of the configured host.


## Question 2
---
Please create a role `nginx_lb` with the following functions.

- The directory of the role should be placed in `~/working/roles/nginx_lb`.
- The role will take a list of IP addresses in the variable `backend_server_list`.
  - The default value for `backend_server_list` is an empty list `[]`.
- This role will install `nginx` on the server and configure the following.
  - The package used for the installation should be obtained from EPEL.
- It will run as a load balancer to port 80 of the IP address set in the `backend_server_list`.


## Question 3
---
Please create a Playbook `~/working/lb_web.yml` with the following settings using the `httpd_myip` and `nginx_lb` roles.

- Configure the three exercise environments as follows.
  - Apply `httpd` to two of them and configure them as web servers.
  - Apply `rp_nginx` to one of them and configure it as a load balancer.
  - Edit the inventory file if necessary for the above settings (not required).
- The load balancer performs load balancing for two web servers.
  - When accessing the load balancer, the pages of the alternate web servers should be displayed. 

## Sample Answers
---
- [httpd_myip](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/roles/httpd_myip)
- [nginx_lb](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/roles/nginx_lb)
- [lb_web.yml](https://github.com/irixjp/katacoda-scenarios/blob/master/master-course-data/assets/solutions/lb_web.yml)
