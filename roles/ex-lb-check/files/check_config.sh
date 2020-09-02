#!/bin/bash

echo_err_and_exit()
{
  echo $1
  exit 1
}

lines=$(grep '\[ex-lb\]' -A 100 /etc/ansible/hosts | grep EX_APISERVER_VIP | grep -v '^#.*'| awk '{print $1}' | uniq -d | wc -l)
if [ $lines -ne 0 ];then
  tip=$(grep '\[ex-lb\]' -A 100 /etc/ansible/hosts | grep EX_APISERVER_VIP | grep -v '^#.*' | awk '{print $1}' | uniq -d | head -n 1)
  echo_err_and_exit "duplicate ip $tip found"
fi

lines=$(grep '\[ex-lb\]' -A 100 /etc/ansible/hosts | grep EX_APISERVER_VIP | grep -v '^#.*' | awk '{print $2}' | awk -F= '{print $2}' | grep master | wc -l)
if [ $lines -ne 1 ];then
  echo_err_and_exit "only one and at least one LB_ROLE=master is required"
fi

lines=$(grep '\[ex-lb\]' -A 100 /etc/ansible/hosts | grep EX_APISERVER_VIP | grep -v '^#.*' | awk '{print $3}' | awk -F= '{print $2}' | uniq -u | wc -l)
if [ $lines -ne 0 ];then
  echo_err_and_exit "EX_APISERVER_VIP should be same"
fi

lines=$(grep '\[ex-lb\]' -A 100 /etc/ansible/hosts | grep EX_APISERVER_VIP | grep -v '^#.*' | awk '{print $4}' | awk -F= '{print $2}' | grep -v '^8443$' | wc -l)
if [ $lines -ne 0 ];then
  echo_err_and_exit "EX_APISERVER_PORT only support 8443 by now"
fi