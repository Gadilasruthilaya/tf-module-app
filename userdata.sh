#!/bin/bash

set-hostname -skip-apply ${component}
labauto ansible
ansible-pull -i localhost, -U http://github.com/Gadilasruthilaya/roboshopshell-ansible-v1.git  main.yml -e role_name=${component} -e env=${env} &>>/opt/ansible.log