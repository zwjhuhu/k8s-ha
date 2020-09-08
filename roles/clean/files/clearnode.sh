#!/bin/bash

# pool

for i in `virsh pool-list | grep active | awk '{print $1}'`
do
  virsh pool-destroy $i
done

for i in `virsh pool-list --all | grep inactive | awk '{print $1}'`
do
  virsh pool-undefine $i
done

grep "/var/lib/libvirt/cstor" /etc/fstab > /tmp/.cstorresult
for i in `cat /tmp/.cstorresult | awk '{print $2}'`
do
  umount -lf $i &>/dev/null
  tmp=`echo $i | sed 's#\/#\\\/#g'`
  sed -i "/${tmp}/"d /etc/fstab
done

if [ -d /etc/sysconfig/cstor/pool ];then
  mv -f /etc/sysconfig/cstor/pool /etc/sysconfig/cstor/pool_old
fi

cd /etc/sysconfig/network-scripts
for i in `ovs-vsctl list-br`
do
  for j in `ovs-vsctl list-ports $i`
  do
    if [ -f ifcfg-${j}.bak ];then
	  echo "delete ifcfg-${i} file"
      rm -f ifcfg-${i}
	  echo "restore ifcfg-${j}.bak to ifcfg-${j}"
      mv -f ifcfg-${j}.bak ifcfg-${j}
	  ovs-vsctl --if-exist del-br $i && ifdown $j && ifup $j
	  break
	fi
  done
done
