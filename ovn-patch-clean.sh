
for ip in `cat hosts | grep -B 100 "private" | grep -A 100 kube-master | awk '{if($0!="")print}' | grep ^[^#] | grep ^[^[]`
do
  echo $ip
  name=$(cat /etc/hosts | grep $ip | awk '{print$2}')
  echo "------Node $name------"
  echo "ssh $name kubeovn-adm stop-central"
  ssh $name kubeovn-adm stop-central
  echo "ssh $name kubeovn-adm stop-worker"
  ssh $name kubeovn-adm stop-worker
  echo "ssh $name rm -rf /etc/openvswitch/*db"
  ssh $name rm -rf /etc/openvswitch/*db
done

