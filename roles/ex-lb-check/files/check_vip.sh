#!/bin/bash

VIP=$1
HOSTIP=$2

echo_err_and_exit()
{
  echo $1
  exit 1
}

if [ "$VIP" == "" -o "$HOSTIP" == "" ];then
  echo_err_and_exit "need params vip hostip"
fi

if [ "$VIP" == "" ];then
  echo_err_and_exit "vip $VIP overlapped with hsotip $HOSTIP"
fi

ping -c 1 -w 3 $VIP &>/dev/null
if [ $? -eq 0 ];then
  echo_err_and_exit "vip $VIP can ping from host"
fi

function ip2num()
{
    ip=$1
    a=`echo $ip | awk -F'.' '{print $1}'`
    b=`echo $ip | awk -F'.' '{print $2}'`
    c=`echo $ip | awk -F'.' '{print $3}'`
    d=`echo $ip | awk -F'.' '{print $4}'`
 
    echo "$(((a<<24)+(b<<16)+(c<<8)+d))"
    return $?
}

vi=$(ip2num $VIP)
hi=$(ip2num $HOSTIP)
prefix=`ip a show | grep "$HOSTIP/" | awk '{print $2}' | awk -F/ '{print $2}'`
let prefix=32-prefix
if [ $prefix -eq 0 ];then
  mask=0
else
  mask=1
fi
let prefix--
while [ $prefix -gt 0 ];
do
  tmp=$((1<<$prefix)) 
  let mask+=tmp
  let prefix--
done
mask=$((~$mask))
vi=$(($vi&$mask))
hi=$(($hi&$mask))
if [ $vi -ne $hi ];then
  echo_err_and_exit "We strongly suggest that vip $VIP and hostip $HOSTIP should use same netmask"
fi