#!/bin/bash

result=/tmp/.check
echo_err_and_exit()
{
  echo $1
  rm -f $result &>/dev/null
  exit 1
}

check_duplicate()
{
  local c=0
  local ret=""
  for i in `cat $result`
  do
    c=`grep "^$i$" $result | wc -l`
    if [ $c -gt 1 ];then
      ret=$i
      break
    fi
  done
  echo $ret
  return $?
}

grep '\[etcd\]' -A 100 /etc/ansible/hosts |grep -B 100 '\[kube-master\]' | grep 'NODE_NAME' | grep -v '^#.*'| awk '{print $1}' > $result 
dup=$(check_duplicate)
if [ "$dup" != "" ];then
  echo_err_and_exit "[etcd] duplicate ip $dup found"
fi

grep '\[etcd\]' -A 100 /etc/ansible/hosts |grep -B 100 '\[kube-master\]' | grep 'NODE_NAME' | grep -v '^#.*'| awk '{print $2}' | awk -F= '{print $2}' > $result
dup=$(check_duplicate)
if [ "$dup" != "" ];then
  echo_err_and_exit "[etcd] duplicate NODE_NAME $dup found"
fi

grep '\[kube-master\]' -A 100 /etc/ansible/hosts |grep -B 100 '\[kube-node\]' | grep -E '^[^#].+$' > $result
dup=$(check_duplicate)
if [ "$dup" != "" ];then
  echo_err_and_exit "[kube-master] duplicate ip $dup found"
fi

rm -f $result &>/dev/null
ansible-playbook setup-master-ha.yml


