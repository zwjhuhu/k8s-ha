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

grep '\[ex-lb\]' -A 100 /etc/ansible/hosts | grep EX_APISERVER_VIP | grep -v '^#.*'| awk '{print $1}' > $result
dup=$(check_duplicate)
if [ "$dup" != "" ];then
  echo_err_and_exit "[ex-lb] duplicate ip $dup found"
fi

grep '\[ex-lb\]' -A 100 /etc/ansible/hosts | grep EX_APISERVER_VIP | grep -v '^#.*' | awk '{print $2}' | awk -F= '{print $2}' | grep master > $result
lines=`cat $result | wc -l`
if [ $lines -ne 1 ];then
  echo_err_and_exit "[ex-lb] only one and at least one LB_ROLE=master is required"
fi

grep '\[ex-lb\]' -A 100 /etc/ansible/hosts | grep EX_APISERVER_VIP | grep -v '^#.*' | awk '{print $3}' | awk -F= '{print $2}' > $result
totalline=`cat $result | wc -l`
for i in `cat $result`
do
  c=`grep "^$i$" $result | wc -l`
  if [ $c -ne $totalline ];then
    echo_err_and_exit "[ex-lb] EX_APISERVER_VIP should be same"
  fi
done

grep '\[ex-lb\]' -A 100 /etc/ansible/hosts | grep EX_APISERVER_VIP | grep -v '^#.*' | awk '{print $4}' | awk -F= '{print $2}' | grep -v '^8443$' > $result
lines=`cat $result | wc -l`
if [ $lines -ne 0 ];then
  echo_err_and_exit "[ex-lb] EX_APISERVER_PORT only support 8443 by now"
fi

rm -f $result &>/dev/null
