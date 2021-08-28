pipeline{
    agent any
    environment{
        MYSQL_DATABASE_PASSWORD = "Clarusway"
        MYSQL_DATABASE_USER = "admin"
        MYSQL_DATABASE_DB = "phonebook"
        MYSQL_DATABASE_PORT = 3306
        PATH="/usr/local/bin/:${env.PATH}"
        ECR_REGISTRY = "646075469151.dkr.ecr.us-east-1.amazonaws.com"
        APP_REPO_NAME= "phonebook/app"
        CFN_KEYPAIR="the-doctor"
        AWS_REGION = "us-east-1"
        CLUSTER_NAME = "mehmet-cluster"
        FQDN = "clarusshop.mehmetafsar.com"
        DOMAIN_NAME = "mehmetafsar.com"
        NM_SP = "phone"
        SEC_NAME = "clarus-cert"
        GIT_FOLDER = sh(script:'echo ${GIT_URL} | sed "s/.*\\///;s/.git$//"', returnStdout:true).trim()
    }
    stages{
        stage('Setup kubectl helm terrform ansible  binaries') {
            steps {
              script {

                println "Setup kubectl helm terrform ansible  binaries..."
                sh """
                  curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/kubectl
                  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
                  chmod 700 get_helm.sh
                  chmod +x ./kubectl
                  sudo mv ./kubectl /usr/local/bin
                  ./get_helm.sh
                  sudo yum install -y yum-utils
                  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
                  sudo yum -y install terraform
                  pip3 install --user ansible
                  pip3 install --user boto3 botocore
                  sudo yum install python-boto3 -y
                """
              }
            }
        } 

        stage("compile"){
           agent{
               docker{
                   image 'python:alpine'
               }
           }
           steps{
               withEnv(["HOME=${env.WORKSPACE}"]) {
                    sh 'pip install -r requirements.txt'
                    sh 'python -m py_compile src/*.py'
                    stash(name: 'compilation_result', includes: 'src/*.py*')
                }
           }
        }

        stage('creating RDS for test stage'){
            agent any
            steps{
                echo 'creating RDS for test stage'
                sh '''
                    RDS=$(aws rds describe-db-instances | grep mysql-instance |cut -d '"' -f 4| head -n 1)  || true
                    if [ "$RDS" == '' ]
                    then
                        aws rds create-db-instance \
                          --db-instance-identifier mysql-instance \
                          --db-instance-class db.t2.micro \
                          --engine mysql \
                          --db-name ${MYSQL_DATABASE_DB} \
                          --master-username ${MYSQL_DATABASE_USER} \
                          --master-user-password ${MYSQL_DATABASE_PASSWORD} \
                          --allocated-storage 20 \
                          --tags 'Key=Name,Value=masterdb'
                          
                    fi
                '''
            script {
                while(true) {
                        
                        echo "RDS is not UP and running yet. Will try to reach again after 10 seconds..."
                        sleep(10)

                        endpoint = sh(script:'aws rds describe-db-instances --region ${AWS_REGION} --query DBInstances[*].Endpoint.Address --output text | sed "s/\\s*None\\s*//g"', returnStdout:true).trim()

                        if (endpoint.length() >= 7) {
                            echo "My Database Endpoint Address Found: $endpoint"
                            env.MYSQL_DATABASE_HOST = "$endpoint"
                            break
                        }
                    }
                }
            }
        }

        stage('create phonebook table in rds'){
            agent any
            steps{
                sh "mysql -u ${MYSQL_DATABASE_USER} -h ${MYSQL_DATABASE_HOST} -p${MYSQL_DATABASE_PASSWORD} < phonebook.sql"
            }
        } 
       
        stage('test'){
            agent {
                docker {
                    image 'python:alpine'
                }
            }
            steps {
                withEnv(["HOME=${env.WORKSPACE}"]) {
                    sh 'python -m pytest -v --junit-xml results.xml src/appTest.py'
                }
            }
            post {
                always {
                    junit 'results.xml'
                }
            }
        }  

        stage('creating .env for docker-compose'){
            agent any
            steps{
                script {
                    echo 'creating .env for docker-compose'
                    sh "cd ${WORKSPACE}"
                    writeFile file: '.env', text: "ECR_REGISTRY=${ECR_REGISTRY}\nAPP_REPO_NAME=${APP_REPO_NAME}:latest"
                }
            }
        }

        stage('creating ECR Repository'){
            agent any
            steps{
                echo 'creating ECR Repository'
                sh '''
                    RepoArn=$(aws ecr describe-repositories | grep ${APP_REPO_NAME} |cut -d '"' -f 4| head -n 1 )  || true
                    if [ "$RepoArn" == '' ]
                    then
                        aws ecr create-repository \
                          --repository-name ${APP_REPO_NAME} \
                          --image-scanning-configuration scanOnPush=false \
                          --image-tag-mutability MUTABLE \
                          --region ${AWS_REGION}
                        
                    fi
                '''
            }
        } 

        stage('build'){
            agent any
            steps{
                sh "docker build -t ${APP_REPO_NAME} ."
                sh 'docker tag ${APP_REPO_NAME} "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }

        stage('push'){
            agent any
            steps{
                sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh 'docker push "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }

        stage('compose'){
            agent any
            steps{
                sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh "docker-compose up -d"
            }
        }

        stage('get-keypair'){
            agent any
            steps{
                sh '''
                    if [ -f "${CFN_KEYPAIR}.pem" ]
                    then 
                        echo "file exists..."
                    else
                        aws ec2 create-key-pair \
                          --region ${AWS_REGION} \
                          --key-name ${CFN_KEYPAIR}.pem \
                          --query KeyMaterial \
                          --output text > ${CFN_KEYPAIR}.pem

                        chmod 400 ${CFN_KEYPAIR}.pem

                        ssh-keygen -y -f ${CFN_KEYPAIR}.pem >> the_doctor_public.pem
                    fi
                '''                
            }
        }

        stage('create-cluster-terraform'){
            agent any
            steps{
                withAWS(credentials: 'mycredentials', region: 'us-east-1') {
                    sh "terraform init" 
                    sh "terraform apply -input=false -auto-approve"
                }    
            }
        }

        stage('Control the cluster') {
            steps {
                echo 'Control the cluster'
            script {
                while(true) {
                        
                        echo "Kube Master is not UP and running yet. Will try to reach again after 10 seconds..."
                        sleep(10)

                        ip = sh(script:'aws ec2 describe-instances --region ${AWS_REGION} --filters Name=tag-value,Values=kube-master  --query Reservations[*].Instances[*].[PublicIpAddress] --output text | sed "s/\\s*None\\s*//g"', returnStdout:true).trim()

                        if (ip.length() >= 7) {
                            echo "Kube Master Public Ip Address Found: $ip"
                            env.MASTER_INSTANCE_PUBLIC_IP = "$ip"
                            sleep(30)
                            break
                        }
                    }
                }
            }
        }
  
        stage('Setting up cluster configuration with ansible') {
            steps {
                echo "Setting up cluster configuration with ansible"
                sh "sed -i 's|{{key_pair}}|${CFN_KEYPAIR}.pem|g' ansible.cfg"
                script {
                    sshagent(credentials : ['my-ssh-key']) {
                    sh '''
                        Ansible=$(ssh -t -t ubuntu@\"${MASTER_INSTANCE_PUBLIC_IP}" -o StrictHostKeyChecking=no ls /home/ubuntu/.kube | grep -i config )  || true
                        if [ "$Ansible" == '' ]
                        then
                            ansible-playbook playbook.yml

                        fi
                    '''
                    }
                }
            }
        }

       stage('Test the infrastructure') {
            steps {
                echo "Testing if the K8s cluster is ready or not Master Public Ip Address: ${MASTER_INSTANCE_PUBLIC_IP}"
                script {
                    sshagent(credentials : ['my-ssh-key']) {
                        while(true) {
                            try {
                              sh 'ssh -t -t ubuntu@\"${MASTER_INSTANCE_PUBLIC_IP}" -o StrictHostKeyChecking=no kubectl get nodes | grep -i master'
                              echo "Successfully created K8s cluster."
                              sleep(60)
                              break
                            }
                            catch(Exception) {
                              echo 'Could not create K8s cluster please wait'
                              sleep(5)   
                            }
                        }
                    }
                }
            }
        }

        stage('Test the k8s svc') {
            steps {
                echo "Testing if the K8s cluster is ready or not Master Public Ip Address: ${MASTER_INSTANCE_PUBLIC_IP}"
                script {
                    sshagent(credentials : ['my-ssh-key']) {
                        while(true) {
                            try {
                              sh 'ssh -t -t ubuntu@\"${MASTER_INSTANCE_PUBLIC_IP}" -o StrictHostKeyChecking=no kubectl get svc -A'
                              echo "Successfully K8s loadbalancer service."
                              sleep(120)
                              break
                            }
                            catch(Exception) {
                              echo 'Could not create K8s cluster please wait'
                              sleep(5)   
                            }
                        }
                    }
                }
            }
        }
        stage('Copy the config file') {
            steps { 
                echo "Copy the config file"
                script {
                    sshagent(credentials : ['my-ssh-key']) {
                        sh '''scp -o StrictHostKeyChecking=no \
                                -o UserKnownHostsFile=/dev/null \
                                -q ubuntu@\"${MASTER_INSTANCE_PUBLIC_IP}":/home/ubuntu/.kube/config /var/lib/jenkins/.kube/
                            ''' 
                    }
                }
            }
        }

        stage('check-cluster'){
            agent any
            steps{
                sh '''
                    #!/bin/sh
                    running=$(sudo lsof -nP -iTCP:80 -sTCP:LISTEN) || true
                    
                    if [ "$running" != '' ]
                    then
                        docker-compose down
                        exist="$(kubectl get nodes | grep -i master)" || true
                        if [ "$exist" == '' ]
                        then
                            
                            echo "we have already created this cluster...."
                        else
                            echo 'no need to create cluster...'
                        fi
                    else
                        echo 'app is not running with docker-compose up -d'
                    fi
                '''
            }
        }


        stage('apply-k8s'){
            agent any
            steps{
                withAWS(credentials: 'mycredentials', region: 'us-east-1') {
                    sh "sed -i 's|{{ECR_REGISTRY}}|$ECR_REGISTRY/$APP_REPO_NAME:latest|g' k8s/deployment-app.yaml"
                    sh '''
                        NameSpaces=$(kubectl get namespaces | grep -i $NM_SP) || true
                        if [ "$NameSpaces" == '' ]
                        then
                            kubectl create namespace $NM_SP
                        else
                            kubectl delete namespace $NM_SP
                            kubectl create namespace $NM_SP
                        fi
                    '''
                    sh "sed -i 's|{{ns}}|$NM_SP|g' k8s/configmap-app.yaml"
                    sh "sed -i 's|{{ns}}|$NM_SP|g' storage-ns.yml"
                    sh "kubectl apply -f  storage-class.yaml"
                    sh "kubectl apply -f  storage-ns.yml"
                    sh "kubectl apply --namespace $NM_SP -f  k8s" 
                    sleep(5)
                }                  
            }
        }

        stage('apply-ingress') {
            steps {
                script {
                        while(true) {
                            try {
                              sh "sed -i 's|{{FQDN}}|$FQDN|g' ingress-service.yaml"
                              sh "kubectl apply --validate=false --namespace $NM_SP -f ingress-service.yaml"
                              echo "Successfully created ingress."
                              break
                            }
                            catch(Exception) {
                              echo 'Could not create ingress please wait'
                              sleep(5)   
                            }
                        }
                    }
                }
            }

        stage('dns-record-control'){
            agent any
            steps{
                withAWS(credentials: 'mycredentials', region: 'us-east-1') {
                    script {
                        
                        env.ZONE_ID = sh(script:"aws route53 list-hosted-zones-by-name --dns-name $DOMAIN_NAME --query HostedZones[].Id --output text | cut -d/ -f3", returnStdout:true).trim()
                        env.ELB_DNS = sh(script:"aws route53 list-resource-record-sets --hosted-zone-id $ZONE_ID --query \"ResourceRecordSets[?Name == '\$FQDN.']\" --output text | tail -n 1 | cut -f2", returnStdout:true).trim()  
                    }
                    sh "sed -i 's|{{DNS}}|$ELB_DNS|g' deleterecord.json"
                    sh "sed -i 's|{{FQDN}}|$FQDN|g' deleterecord.json"
                    sh '''
                        RecordSet=$(aws route53 list-resource-record-sets   --hosted-zone-id $ZONE_ID   --query ResourceRecordSets[] | grep -i $FQDN) || true
                        if [ "$RecordSet" != '' ]
                        then
                            aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file://deleterecord.json
                        
                        fi
                    '''
                    
                }                  
            }
        }

        stage('dns-record'){
            agent any
            steps{
                withAWS(credentials: 'mycredentials', region: 'us-east-1') {
                    script {
                        env.ELB_DNS = sh(script:'aws elbv2 describe-load-balancers --query LoadBalancers[].DNSName --output text | sed "s/\\s*None\\s*//g"', returnStdout:true).trim()
                        env.ZONE_ID = sh(script:"aws route53 list-hosted-zones-by-name --dns-name $DOMAIN_NAME --query HostedZones[].Id --output text | cut -d/ -f3", returnStdout:true).trim()   
                    }
                    sh "sed -i 's|{{DNS}}|$ELB_DNS|g' dnsrecord.json"
                    sh "sed -i 's|{{FQDN}}|$FQDN|g' dnsrecord.json"
                    sh "aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file://dnsrecord.json"
                    
                }                  
            }
        }

        stage('ssl-tls-record'){
            agent any
            steps{
                withAWS(credentials: 'mycredentials', region: 'us-east-1') {
                    sh "kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml"
                    sh "helm repo add jetstack https://charts.jetstack.io"
                    sh "helm repo update"
                    sh '''
                        NameSpace=$(kubectl get namespaces | grep -i cert-manager) || true
                        if [ "$NameSpace" == '' ]
                        then
                            kubectl create namespace cert-manager
                        else
                            helm delete cert-manager --namespace cert-manager
                            kubectl delete namespace cert-manager
                            kubectl create namespace cert-manager
                        fi
                    '''
                    sh """
                      helm install cert-manager jetstack/cert-manager \
                      --namespace cert-manager \
                      --version v0.11.1 \
                      --set webhook.enabled=false \
                      --set installCRDs=true
                    """
                    sh """
                      sudo openssl req -x509 -nodes -days 90 -newkey rsa:2048 \
                          -out clarusway-cert.crt \
                          -keyout clarusway-cert.key \
                          -subj "/CN=$FQDN/O=$SEC_NAME"
                    """
                    sh '''
                        SecretNm=$(kubectl get secrets | grep -i $SEC_NAME) || true
                        if [ "$SecretNm" == '' ]
                        then
                            kubectl create secret --namespace $NM_SP  tls $SEC_NAME \
                                --key clarusway-cert.key \
                                --cert clarusway-cert.crt
                        else
                            kubectl delete secret --namespace $NM_SP $SEC_NAME
                            kubectl create secret --namespace $NM_SP tls $SEC_NAME \
                                --key clarusway-cert.key \
                                --cert clarusway-cert.crt
                        fi
                    '''
                    sleep(5)
                    sh "sed -i 's|{{FQDN}}|$FQDN|g' ingress-service.yaml" 
                    sh "sudo mv -f ingress-service-https.yaml ingress-service.yaml" 
                    sh "kubectl apply --namespace $NM_SP -f ssl-tls-cluster-issuer.yaml"
                    sh "sed -i 's|{{FQDN}}|$FQDN|g' ingress-service.yaml"
                    sh "sed -i 's|{{SEC_NAME}}|$SEC_NAME|g' ingress-service.yaml"
                    sh "kubectl apply --namespace $NM_SP -f ingress-service.yaml"
                    sh "sudo mv -f /var/lib/jenkins/.kube/config /home/ec2-user/.kube/"
                    sh "sudo chmod 777 /home/ec2-user/.kube/config"            
                }                  
            }
        }
    
    }
    post {
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
        }
        failure {
            withAWS(credentials: 'mycredentials', region: 'us-east-1') {
                sh "rm -rf '${WORKSPACE}/.env'"
                sh """
                aws ec2 detach-volume \
                  --volume-id ${EBS_VOLUME_ID} \
                """
                sh """
                aws ecr delete-repository \
                  --repository-name ${APP_REPO_NAME} \
                  --region ${AWS_REGION}\
                  --force
                """
                sh """
                aws rds delete-db-instance \
                  --db-instance-identifier mysql-instance \
                  --skip-final-snapshot \
                  --delete-automated-backups
                """
                sh """
                aws ec2 delete-key-pair \
                  --key-name ${CFN_KEYPAIR}.pem
                """
                sh "rm -rf '${WORKSPACE}/the_doctor_public.pem'"
                sh "rm -rf '${WORKSPACE}/${CFN_KEYPAIR}.pem'"
                sh "eksctl delete cluster ${CLUSTER_NAME}"
                sh "docker rm -f '\$(docker ps -a -q)'"
                sh "kubectl delete -f k8s"
            }    
        }
        success {
            echo "You are Greattt...You can visit https://$FQDN"
        }
    }
}

