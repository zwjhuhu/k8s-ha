vip=$(cat hosts | grep -A 3 ex-lb | grep master | awk '{print$3}' | awk -F"=" '{print$2}')

for ip in `cat hosts | grep -B 100 "private" | grep -A 100 kube-master | awk '{if($0!="")print}' | grep ^[^#] | grep ^[^[]`
do
  name=$(cat /etc/hosts | grep $ip | awk '{print$2}')
  echo "ssh $name sed -i 's/127.0.0.1/$vip/g' /root/.kube/config"
  ssh $name sed -i "s/127.0.0.1/$vip/g" /root/.kube/config
  echo "ssh $name sed -i 's/$ip/$vip/g' /root/.kube/config"
  ssh $name sed -i "s/$ip/$vip/g" /root/.kube/config
  ssh $name sed -i "s/6443/8443/g" /root/.kube/config
  echo "ssh $name systemctl restart kubelet"
  ssh $name systemctl restart kubelet
done
