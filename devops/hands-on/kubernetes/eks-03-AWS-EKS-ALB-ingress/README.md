# Hands-on EKS-ALB : AWS LoadBalancer Controller (ALB) and Ingress with EKS

Purpose of the this hands-on training is to give students the knowledge of AWS LoadBalancer Controller and Ingress with EKS.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- Learn to Create and Manage EKS Cluster with eksctl.

- Understand the Ingress and AWS LoadBalancer Controller (ALB) Usage.

## Outline

- Part 1 - Installing kubectl and eksctl on Amazon Linux 2

- Part 2 - Creating the Kubernetes Cluster on EKS

- Part 3 - Ingress and AWS LoadBalancer Controller (ALB)

## Prerequisites

1. AWS CLI with Configured Credentials

2. kubectl installed

3. eksctl installed

For information on installing or upgrading eksctl, see [Installing or upgrading eksctl.](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html#installing-eksctl)

## Part 1 - Installing kubectl and eksctl on Amazon Linux 2

### Install git, helm and kubectl

- Launch an AWS EC2 instance of Amazon Linux 2 AMI (type t2.micro) with security group allowing SSH.

- Connect to the instance with SSH.

- Update the installed packages and package cache on your instance.

```bash
sudo yum update -y
```

- Install git.

```bash
sudo yum install git
```

- Install helm.

```bash
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version --short
```

- Download the Amazon EKS vended kubectl binary.

```bash
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/kubectl
```

- Apply execute permissions to the binary.

```bash
chmod +x ./kubectl
```

- Move kubectl to a folder that is in your path.

```bash
sudo mv ./kubectl /usr/local/bin
```

- After you install kubectl , you can verify its version with the following command:

```bash
kubectl version --short --client
```

### Install eksctl

- Download and extract the latest release of eksctl with the following command.

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
```

- Move the extracted binary to /usr/local/bin.

```bash
sudo mv /tmp/eksctl /usr/local/bin
```

- Test that your installation was successful with the following command.

```bash
eksctl version
```

## Part 2 - Creating the Kubernetes Cluster on EKS

- If needed create ssh-key with commnad `ssh-keygen -f ~/.ssh/id_rsa`

- Configure AWS credentials.

```bash
aws configure
```

- Create an EKS cluster via `eksctl`. It will take a while.

```bash
eksctl create cluster --region us-east-2 --node-type t2.medium --nodes 1 --nodes-min 1 --nodes-max 2 --name mycluster

or

eksctl create cluster \
 --name mycluster \
 --version 1.18 \
 --region us-east-2 \
 --nodegroup-name my-nodes \
 --node-type t2.medium \
 --nodes 1 \
 --nodes-min 1 \
 --nodes-max 2 \
 --ssh-access \
 --ssh-public-key  ~/.ssh/id_rsa.pub \
 --managed
```

- Note that the default value for node-type is m5.large.

```bash
$ eksctl create cluster --help
```

- Show the aws `eks service` on aws management console and explain `eksctl-mycluster-cluster` stack on `cloudformation service`.

## Part 3 - Ingress and AWS LoadBalancer Controller (ALB)

- Firstly, we deploy the AWS Load Balancer Controller to our Amazon EKS cluster according to [AWS Load Balancer Controller user guide](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)

- Verify that the controller is installed.

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
```

Output:

```bash
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
aws-load-balancer-controller   2/2     2            2           84s
```

### Application

> Copy the k8s folder to ec2-instance with `scp command`.

```bash
scp -i <pem-file> -r <eks-03-AWS-EKS-ALB-ingress/k8s> ec2-user@<ec2-instance-public-ip>:~/k8s
```

The directory structure is as follows:

```bash
.
├── k8s
│   ├── account-deploy.yaml
│   ├── account-service.yaml
│   ├── inventory-deploy.yaml
│   ├── inventory-service.yaml
│   ├── shipping-deploy.yaml
│   ├── shipping-service.yaml
│   ├── storefront-deploy.yaml
│   └── storefront-service.yaml
```

- Let's check the state of the cluster and see that evertyhing works fine.

```bash
kubectl cluster-info
kubectl get node
```

- Create an `ingress.yaml` file.

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-clarusshop
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    # Health Check Settings
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP 
    alb.ingress.kubernetes.io/healthcheck-port: traffic-port
    #Important Note:  Need to add health check path annotations in service level if we are planning to use multiple targets in a load balancer    
    #alb.ingress.kubernetes.io/healthcheck-path: /usermgmt/health-status
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '15'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    alb.ingress.kubernetes.io/success-codes: '200'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '2'
spec:
  rules:
  - http:
      paths:
      - path: /account
        backend:
            serviceName: account-service
            servicePort: 80
      - path: /inventory
        backend:
            serviceName: inventory-service
            servicePort: 80
      - path: /shipping
        backend:
            serviceName: shipping-service
            servicePort: 80
      - path: /
        backend:
          serviceName: storefront-service
          servicePort: 80
```

- Launch the aplication.

```bash
kubectl apply -f k8s
```

- List the ingress.

```bash
kubectl get ingress
```

Output:

```bash
NAME                 CLASS    HOSTS   ADDRESS                                                                 PORTS   AGE
ingress-clarusshop   <none>   *       k8s-default-ingressc-38a2e90a69-465630546.us-east-2.elb.amazonaws.com   80      89s
```

- On browser, type this  ( k8s-default-ingressc-38a2e90a69-465630546.us-east-2.elb.amazonaws.com ), you must see the clarusshop web page. If you type `k8s-default-ingressc-38a2e90a69-465630546.us-east-2.elb.amazonaws.com/account`, then the account page will be opened and so on.

>**Important Note: In order for Ingress to run smoothly, the paths specified in the application and the paths in ingress must be the same. For example, application microservice must be published from `/account` path.**

### Adding hostname and certificate to ALB.

- For now, our application is working on http. Now, we add an host name and return the http to https.

- Firstly, bind ingress address to an host nane in the route53 service.

- Then update the ingress.yaml as below. Don't forgot to change certificate-arn.

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-clarusshop
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    # Health Check Settings
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP 
    alb.ingress.kubernetes.io/healthcheck-port: traffic-port
    #Important Note:  Need to add health check path annotations in service level if we are planning to use multiple targets in a load balancer    
    #alb.ingress.kubernetes.io/healthcheck-path: /usermgmt/health-status
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '15'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    alb.ingress.kubernetes.io/success-codes: '200'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '2'
    # To use certificate add annotations below.
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-2:046402772087:certificate/dae75cd6-8d82-420c-bed1-1ea132ec3d37
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
spec:
  rules:
    - host: clarusshop.clarusway.us
      http:
        paths:
          - path: /* # SSL Redirect Setting
            backend:
                serviceName: ssl-redirect
                servicePort: use-annotation         
          - path: /account
            backend:
              serviceName: account-service
              servicePort: 80
          - path: /inventory
            backend:
              serviceName: inventory-service
              servicePort: 80
          - path: /shipping
            backend:
              serviceName: shipping-service
              servicePort: 80
          - path: /
            backend:
              serviceName: storefront-service
              servicePort: 80
```

- Update the ingress.

```bash
kubectl apply -f ingress.yaml
```

- List the ingress.

```bash
kubectl get ingress
```

Output:

```bash
NAME                 CLASS    HOSTS                     ADDRESS                                                                  PORTS   AGE
ingress-clarusshop   <none>   clarusshop.clarusway.us   k8s-default-ingressc-38a2e90a69-1914587084.us-east-2.elb.amazonaws.com   80      16m
```

- Create an `A record` for your host on `route53 service` like `clarusshop.<host-name>`

- On browser, type `clarusshop.clarusway.us`, you must see the clarusshop web page. If you type `clarusshop.clarusway.us/account`, then the account page will be opened and so on.

- Note that the web page is published as https.

- Try to reach web page as http. `http://clarusshop.clarusway.us`.

- It redirect to https page thanks to `alb.ingress.kubernetes.io/actions.ssl-redirect`.

- Delete the cluster

```bash
$ eksctl get cluster
NAME            REGION
mycluster       us-east-2
$ eksctl delete cluster mycluster
```