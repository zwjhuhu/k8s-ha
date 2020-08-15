#!/bin/bash

ENCAP_IP=$1
OVS_SET="ovs-vsctl set open ."
$OVS_SET extetnal_ids:ovn-bridge=br-int
$OVS_SET extetnal_ids:ovn-encap-type=geneve
$OVS_SET extetnal_ids:ovn-encap-ip=$ENCAP_IP
$OVS_SET extetnal_ids:ovn-nb=unix:/var/run/openvswitch/ovnsb_nb.sock
$OVS_SET extetnal_ids:ovn-remote=unix:/var/run/openvswitch/ovnsb_db.sock

