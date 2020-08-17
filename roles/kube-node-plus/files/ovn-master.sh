#!/bin/bash

ENCAP_IP=$1
OVS_SET="ovs-vsctl set open ."
$OVS_SET external_ids:ovn-bridge=br-int
$OVS_SET external_ids:ovn-encap-type=geneve
$OVS_SET external_ids:ovn-encap-ip=$ENCAP_IP
$OVS_SET external_ids:ovn-nb=unix:/var/run/openvswitch/ovnsb_nb.sock
$OVS_SET external_ids:ovn-remote=unix:/var/run/openvswitch/ovnsb_db.sock

