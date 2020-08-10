vip=$(cat hosts | grep -A 3 ex-lb | grep master | awk '{print$3}' | awk -F"=" '{print$2}')
echo $vip

ovnnb=""
ovnsb=""
for ip in `cat hosts | grep -B 100 "kube-node" | grep -A 100 kube-master | awk '{if($0!="")print}' | grep ^[^#] | grep ^[^[]`
do
  ovnnb=$ovnnb",tcp:"$ip":6641"
  ovnsb=$ovnsb",tcp:"$ip":6642"
done

echo "ovnnb="${ovnnb:1} > ovn.conf
echo "ovnsb="${ovnsb:1} >> ovn.conf

leader=""
cmd=""

for ip in `cat hosts | grep -B 100 "kube-node" | grep -A 100 kube-master | awk '{if($0!="")print}' | grep ^[^#] | grep ^[^[]`
do
  echo "------Master $name------"
  if [[ -z $leader ]]
  then
    leader=$ip
    cmd="--db-nb-addr=$ip --db-nb-create-insecure-remote=yes --db-sb-addr=$ip --db-sb-create-insecure-remote=yes --db-nb-cluster-local-addr=$ip --db-sb-cluster-local-addr=$ip --ovn-northd-nb-db=${ovnnb:1} --ovn-northd-sb-db=${ovnsb:1}"
  else  
    cmd="--db-nb-addr=$ip --db-nb-create-insecure-remote=yes --db-sb-addr=$ip --db-sb-create-insecure-remote=yes --db-nb-cluster-local-addr=$ip --db-sb-cluster-local-addr=$ip --ovn-northd-nb-db=${ovnnb:1} --ovn-northd-sb-db=${ovnsb:1} --db-nb-cluster-remote-addr=$leader --db-sb-cluster-remote-addr=$leader"
  fi
  
  name=$(cat /etc/hosts | grep $ip | awk '{print$2}')
  rm -f $name.sdb
  cp systemctl/ovn-ovsdb.service $name.sdb
  sed -i "s/CMD/$cmd/g" $name.sdb
  echo "scp $name.sdb $name:/usr/lib/systemd/system/ovn-ovsdb.service"
  scp $name.sdb $name:/usr/lib/systemd/system/ovn-ovsdb.service
 
  rm -f $name.ndb
  cp systemctl/ovn-northd.service $name.ndb
  sed -i "s/CMD/$cmd/g" $name.ndb
  echo "scp $name.ndb $name:/usr/lib/systemd/system/ovn-northd.service"
  scp $name.ndb $name:/usr/lib/systemd/system/ovn-northd.service

  rm -f $name.cc
  cp systemctl/ovn-northd.service $name.cc
  sed -i "s/CMD/$cmd/g" $name.cc
  echo "scp $name.cc $name:/usr/lib/systemd/system/ovn-controller.service"
  scp $name.cc $name:/usr/lib/systemd/system/ovn-controller.service

  scp systemctl/*ovsschema $name:/usr/share/openvswitch/
  scp ovn.conf $name:/etc/ovn.conf
  ssh $name systemctl daemon-reload
  echo "ssh $name systemctl start openvswitch"
  ssh $name systemctl start openvswitch
  echo "ssh $name systemctl enable openvswitch"
  ssh $name systemctl enable openvswitch
  echo "ssh $name kubeovn-adm start-central"
  ssh $name kubeovn-adm start-central
  echo "ssh $name kubeovn-adm start-worker"
  ssh $name kubeovn-adm start-worker
done


for ip in `cat hosts | grep -B 100 "private" | grep -A 100 kube-node | awk '{if($0!="")print}' | grep ^[^#] | grep ^[^[]`
do
  name=$(cat /etc/hosts | grep $ip | awk '{print$2}')
  echo "------Node $name------"
  scp ovn.conf $name:/etc/ovn.conf
  echo "ssh $name systemctl start openvswitch"
  ssh $name systemctl start openvswitch
  echo "ssh $name systemctl enable openvswitch"
  ssh $name systemctl enable openvswitch
  echo "ssh $name kubeovn-adm start-worker"
  ssh $name kubeovn-adm start-worker
done
