# Hands-on Kubernetes-11 : Kubernetes Backup and Restore

The purpose of this hands-on training is to give students the knowledge of taking backup and restoring a cluster from backup.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Explain the etcd.

- Take a cluster backup.

- Restore cluster from backup.

## Outline

- Part 1 - Setting up the Kubernetes Cluster

- Part 2 - Cluster Backup

- Part 3 - Restore Cluster From Backup.

## Part 1 - Setting up the Kubernetes Cluster

- Launch a Kubernetes Cluster of Ubuntu 20.04 with two nodes (one master, one worker) using the [Cloudformation Template to Create Kubernetes Cluster](../kubernetes-02-basic-operations/cfn-template-to-create-k8s-cluster.yml). *Note: Once the master node up and running, the worker node automatically joins the cluster.*

>*Note: If you have a problem with the Kubernetes cluster, you can use this link for the lesson.*
>https://www.katacoda.com/courses/kubernetes/playground

- Check if Kubernetes is running and nodes are ready.

```bash
kubectl cluster-info
kubectl get no
```

## Part 2 - Cluster Backup

- `etcd` is a consistent and highly-available key-value store used as Kubernetes' backing store for all cluster data.

- Firstly, we will check the `etcd-kube20-master` pod in kube-system namespace is running.

```bash
kubectl get po etcd-kube20-master -n kube-system
```

- Let's find, at what address can we reach the ETCD cluster from the kube20-master node?

```bash
kubectl describe pod etcd-kube20-master -n kube-system
```

- Check the --listen-client-urls. We will get an ip address as below.

```bash
--listen-client-urls=https://127.0.0.1:2379,https://192.168.99.102:2379
```

- Now, let's see where the ETCD server certificate file is located.

```bash
kubectl describe pod etcd-kube20-master -n kube-system
```

- Check the --cert-file. We will get a PATH as below.

```yaml
--cert-file=/etc/kubernetes/pki/etcd/server.crt
```

- Check this path.

```bash
ls /etc/kubernetes/pki/etcd
```

- Now, let's see where the ETCD server key file is located.

```bash
kubectl describe pod etcd-kube20-master -n kube-system
```

- Check the --key-file. We will get a PATH as below.

```yaml
--key-file=/etc/kubernetes/pki/etcd/server.key
```

- This time we will learn where the ETCD CA Certificate file is located?

```bash
kubectl describe pod etcd-kube20-master -n kube-system
```

- Check the --trusted-ca-file. We will get a PATH as below.

```yaml
--trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
```

### Data Directory

- When first started, etcd stores its configuration into a data directory specified by the data-dir configuration parameter.

- A user should avoid restarting an etcd member with a data directory from an out-of-date backup. Using an out-of-date data directory can lead to inconsistency.

- Let's see where the data directory of etcd is.

```bash
kubectl describe pod etcd-kube20-master -n kube-system
```
- Check the --data-dir. We will get a PATH as below.

```bash
--data-dir=/var/lib/etcd
```

### etcdctl commands

- `etcdctl` is the CLI tool used to interact with `etcd`.

- `etcdctl` can interact with ETCD Server using 2 API versions. Version 2 and Version 3.  

- The API version used by etcdctl to speak to etcd may be set to version 2 or 3 via the ETCDCTL_API environment variable. By default, etcdctl on master (3.4) uses the v3 API, and earlier versions (3.3 and earlier) default to the v2 API.

- We will install etcdctl.

```bash
sudo apt  install etcd-client
```

- Let's see the version of `etcdctl`.

```bash
etcdctl --version # This is the version 2 command.
```

or 

```bash
etcdctl version # This is the version 3 command.
```

- To set the version of API set the environment variable ETCDCTL_API command.

```bash
export ETCDCTL_API=3
```

- Now we are ready for backup and restore operations. But before, we run an application.

- Create a deployment file

```bash
cat << EOF > clarusshop.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: clarusshop-deployment
  labels:
    app: clarusshop
spec:
  replicas: 3
  selector:
    matchLabels:
      app: clarusshop
  template:
    metadata:
      labels:
        app: clarusshop
    spec:
      containers:
      - name: clarusshop
        image: clarusway/clarusshop
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: clarusshop-service
spec:
  selector:
    app: clarusshop
  type: NodePort
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30001
EOF
```

- Execute the application.

```bah
kubectl apply -f clarusshop.yaml
```

- Check the application.

```bash
kubectl get po
kubectl get svc
```

- We can visit `http://<public-node-ip>:30001` and access the application or we can use curl command.

```bash
curl localhost:30001
```

> Do not forget to open 30001 port from the security group.

- It's time to take a backup of the cluster. For this, we will use `etcd snapshot save` command.

```bash
sudo ETCDCTL_API=3 etcdctl --endpoints=https://[127.0.0.1]:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/snapshot-backup.db
```

These fields are mandatory.

> --cacert : Verify certificates of TLS-enabled secure servers using this CA bundle.
>
> --cert   : Identify secure client using this TLS certificate file.
>
> --key    : Identify secure client using this TLS key file
>
> --endpoints=[127.0.0.1:2379] : This is the default as ETCD is running on master node and exposed on localhost 2379.

- Now we have a backup file named snapshot-backup.db. From this file, we restore our cluster.

- Let's assume that we have a problem and we can not reach the application. To simulate this one delete the applicatiın.

```bash
kubectl delete -f clarusshop.yaml
```

- Check that application is deleted.

```bash
kubectl get po
```

- And we decide the restore the cluster immediately.

```bash
sudo ETCDCTL_API=3 etcdctl  snapshot restore /opt/snapshot-backup.db \
--data-dir /var/lib/etcd-backup
```

- Then, we will modify etcd configuration file to use the new data directory. 

- But before that we should take out the manifest file of kube-api server which is named as ```kube-apiserver.yaml```. This file and other three files in the same directory are called static pods and they're created by kubelet service while the cluster is being created. If you want to modify any of these files under ```etc/kubernetes/manifests/``` folder, you should take out the kube-apiserver.yaml file out of this special directory. So that any api request would not be tried to be processed. So take the ```kube-apiserver.yaml``` file out of this directory first, then take out the ```etcd.yaml``` file out of this directory. After that modify etcd.yaml file and put it back to the ```manifests``` folder. Then, at the end put the kube-apiserver.yaml file back into the manifests folder.

```bash
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml ~/
sudo mv /etc/kubernetes/manifests/etcd.yaml ~/
sudo vi ~/etcd.yaml
```

- Modify the files as shown below:

```yaml
  volumes:
  - hostPath:
      path: /var/lib/etcd-backup
      type: DirectoryOrCreate
    name: etcd-data
```

- We have restored the etcd snapshot to a new path on the kube20-master - /var/lib/etcd-backup, so, the only change to be made in the YAML file, is to change the hostPath for the volume called etcd-data from the old directory (/var/lib/etcd) to the new directory /var/lib/etcd-backup as below.

```bash
sudo mv ~/etcd.yaml /etc/kubernetes/manifests/
sudo mv ~/kube-apiserver.yaml /etc/kubernetes/manifests/ 
```

- Restart the kubelet service.

```bash
sudo systemctl restart kubelet
```

- Wait a while and check the app is running.

```bash
kubectl get deploy
kubectl get svc
curl localhost:30001
```

- **NOTE:** If you are using nginx ingress controller and ingress in your application you may need to redeploy the nginx ingress controller and the ingress.

```bash

kubectl delete -f <ingress-service.yaml>

kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.45.0/deploy/static/provider/aws/deploy.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.45.0/deploy/static/provider/aws/deploy.yaml

kubectl apply -f <ingress-service.yaml>
```