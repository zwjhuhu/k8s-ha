#!/bin/bash

ENCAP_IP=$1
# if master and node in same host do nothing
/opt/kube/bin/kubectl get node --show-labels | grep -q "master.ha.ip=192.168.96.118"
if [ $? -eq 0 ];then
  exit 0
fi
OVS_SET="ovs-vsctl set open ."
$OVS_SET external_ids:ovn-bridge=br-int
$OVS_SET external_ids:ovn-encap-type=geneve
$OVS_SET external_ids:ovn-encap-ip=$ENCAP_IP
if [ -e /etc/ovn.conf ];then
  OVN_NB=`cat /etc/ovn.conf | grep ovnnb | awk -F= '{print $2}'`
  OVN_SB=`cat /etc/ovn.conf | grep ovnsb | awk -F= '{print $2}'`
  if [ "$OVN_NB" != "" ];then
    $OVS_SET external_ids:ovn-nb=$OVN_NB
  fi
  if [ "$OVN_SB" != "" ];then
    $OVS_SET external_ids:ovn-remote=$OVN_SB
  fi
fi
