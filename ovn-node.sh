#!/bin/bash

ENCAP_IP=$1
OVS_SET="ovs-vsctl set open ."
$OVS_SET extetnal_ids:ovn-bridge=br-int
$OVS_SET extetnal_ids:ovn-encap-type=geneve
$OVS_SET extetnal_ids:ovn-encap-ip=$ENCAP_IP
if [ -e /etc/ovn.conf ];then
  OVN_NB=`cat /etc/ovn.conf | grep ovnnb | awk -F= '{print $2}'`
  OVN_SB=`cat /etc/ovn.conf | grep ovnsb | awk -F= '{print $2}'`
  $OVS_SET extetnal_ids:ovn-nb=$OVN_NB
  $OVS_SET extetnal_ids:ovn-remote=$OVN_SB
fi
