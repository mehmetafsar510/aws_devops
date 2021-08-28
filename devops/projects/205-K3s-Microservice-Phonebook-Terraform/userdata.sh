#! /bin/bash
hostnamectl set-hostname ${nodename} &&
curl -sfL https://get.k3s.io | sh -s - server \
--datastore-endpoint="mysql://${dbuser}:${dbpass}@tcp(${db_endpoint})/${dbname}" \
--write-kubeconfig-mode 644 \
--tls-san=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
--token="th1s1sat0k3n!"
sleep 60
cd /home/ubuntu
git clone https://github.com/mehmetafsar510/jenkins-k8s.git
chmod 777 /home/ubuntu/jenkins-k8s/start.sh
sh /home/ubuntu/jenkins-k8s/start.sh
sh /home/ubuntu/jenkins-k8s/deploy.sh