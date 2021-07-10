# Hands-on Kubernetes-10 : Automate Kubernetes Cluster Creation with Terraform and Ansible

The purpose of this hands-on training is to give students the knowledge of automating cluster creation with terraform and ansible.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Explain creation of the infrastructure needed for a Kubernetes Cluster.

- Explain how to configure an infrastructure as a Kubernetes cluster with Ansible.

## Outline

- Part 1 - Install Terraform, Ansible and Kubectl on AWS EC2

- Part 2 - Create the infrastructure with Terraform

- Part 3 - Configure the infrastructure with Ansible

- Part 4 - Deploy a Sample Applications

## Part 1 - Install Terraform, Ansible and Kubectl on AWS EC2

- Launch an AWS EC2 (t2.micro) on Amazon Linux 2 AMI with security group allowing SSH.

- Tag the instance ```Name``` as ```K8s-Controller```.

- Connect to the instance with SSH.

- Update the installed packages and package cache on your instance.

```bash
$ sudo yum update -y
```

> - In Amazon Linux instance we have just two repository under the /etc/yum.repos.d directory and this repos doesn't have terraform packages. If we want to install terraform, we need to add terraform repo, to the directory of yum.repos.d.

- Use yum-config-manager to add the official HashiCorp Linux repository to the directory of /etc/yum.repos.d.

```bash
$ sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
```

- Go to /etc/yum.repos.d/ folder and show that the file ```hashicorp.repo``` is added.

- Install Terraform.

```bash
$ sudo yum -y install terraform
```

- Verify that the installation is succefful.

```bash
$ terraform version
```

- Run the following commands to install Ansible.

```bash
pip3 install --user ansible
```

- To confirm the installation of Ansible, run the following command.

```bash
$ ansible --version
```

- Patially clone this hands-on folder (kubernetes-10-automate-k8s-cluster-creation-with-terraform-and-ansible) into your Amazon Linux 2 Machine.

```bash
sudo yum install -y git
mkdir <repo>
cd <repo>
git init
git remote add origin <origin-url>
git config core.sparseCheckout true
echo "subdirectory/under/repo/" >> .git/info/sparse-checkout  # do not put the repository folder name in the beginning
git pull origin <branch-name>
```

- Go into the cloned folder, find the folders named ```terraform```, ```ansible```, ```ingress-yaml-files``` and  move them under your home folder.

```bash
mv terraform ansible ingress-yaml-files ~/
```

- Download the Amazon EKS vended kubectl binary.

```bash
$ curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/kubectl
```

- Apply execute permissions to the binary.

```bash
$ chmod +x ./kubectl
```

- Move kubectl to a folder that is in your path.

```bash
$ sudo mv ./kubectl /usr/local/bin
```

- After you install kubectl , you can verify its version with the following command:

```bash
$ kubectl version --short --client
```

## Part 2 - Create the infrastructure with Terraform

- Configure AWS credentials.

```bash
aws configure
```

- Cd into the ```terraform``` folder.

```bash
cd ~/terraform
```

- Explain what this terraform file does:
    - Creates 3 Ubuntu instances.
    - Creates 3 Security group (1 for master node, 1 for worker node, 1 for mutual communication since there is no sequence between master and worker security groups).
    - Master and Worker nodes uses roles created under IAM module.
    - Outputs the public ip numbers of the instances.

- Modify the ```key_name``` parts (3 different lines for 3 instances) in the main.tf file.

- Run the commands below to create the infrastructure.

```bash
terraform init
terraform apply
```

- Wait for the instances to show up in the AWS Console and check whether they are healthy or not. 


## Part 3 - Configure the infrastructure with Ansible

- This time cd into the ```ansible``` folder.

```bash
cd ~/ansible
```

- Cat the content of the ansible.cfg file. Explain the fields. Draw attentation to the key file and its existence.

- Go to your local environment and transfer the key file with the scp command below.

```bash
scp -i ~/<path-to-your-key> <path-to-your-key> ec2-user@<your-controller-instance-ip>:/home/ec2-user/ansible/
```

- Cat the content of the ```./dynamic-inventory-aws_ec2.yml``` file.

- Show the tags necessary to fetch the instances to create the cluster. Compare these tags with the ones on the main.tf file.

- Cat the content of the clusterconfig-base.yml file.

- Explain the fields in this file:
    - ```controlePlaneEndpoint:``` Private IP address of the master node. (It will be paste programmatically.)
    - ```podSubnet:``` Pod CIDR is necessary for Flannel CNI Plug-in.
    - ```cloud-provider:``` With the value ```external``` Kubernetes cluster will be aware of the cloud controller manager. So that the cloud controller manager can implement specific tasks related to nodes, services etc.

- Cat the content of the playbook.yml file.

- Explain the tasks in the last play about ```patching nodes, deploying the AWS CSI Driver and Cloud Controller Manager```.

- Run the playbook with the command below.

```bash
pip3 install --user boto3 botocore  # These dependencies are needed to use a dynamic inventory.
ansible-playbook playbook.yml
```

- After a successful playbook operation, We will have k8s cluster ready to use.

- So ssh into the master node.

- Run the command below to check if the nodes in the cluster are ready:

```bash
kubectl get node
```

- Run the command below to check if we have the LoadBalancer of the ingress:

```bash
kubectl get svc -A
```

- Go to the address of the ingress load balancer.

- You should see 404 page of the Nginx application server. (This may take a few minutes...)

- Now, run the command below:

```bash
kubectl get deploy -A
```

- If you see the output of the default nginx controller deployment (ingress-nginx-controller) and the deployment of the CSI Driver (ebs-csi-controller) then it means that we have deployed the Cloud Controller Manager, EBS CSI Driver and the ingress controller successfully. 


## Part 4 - Deploy a Sample Applications

- Now, cd into the ~/.kube folder.

```bash
cd ~/.kube
```

- Copy the content of the ```config``` file.

- Go to ```K8s-Controller``` instance 

- Run the command below to create a .kube folder under the home folder and create config file:

```bash
mkdir ~/.kube
cd ~/.kube
vi config
```

- Paste the content of the ```KUBECONFIG``` file.

- Run the command below to check whether we can access to the cluster.

```bash
kubectl get node
```

- Cd into the ```ingress-yaml-files``` folder.

- Run the commands below.

```bash
kubectl apply -f ingress-service.yaml
kubectl apply -f storage-class.yaml
kubectl apply -f to-do
kubectl apply -f php-apache
```

- Check to see the applications' output on the url of the ingress load balancer.
