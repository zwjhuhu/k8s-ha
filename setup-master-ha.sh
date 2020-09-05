#!/bin/bash

#do check role anisble won't exit when error, so do check separetely
bash roles/ex-lb-check/files/check_config.sh

if [ $? -eq 0 ];then
  ansible-playbook check-config.yml
else
  echo "ERROR: please check config in /etc/ansible/hosts "
  exit 1
fi

if [ $? -eq 0 ];then
  ansible-playbook setup-master-ha.yml
else
  echo "ERROR: please check config in /etc/ansible/hosts "
  exit 1
fi 

