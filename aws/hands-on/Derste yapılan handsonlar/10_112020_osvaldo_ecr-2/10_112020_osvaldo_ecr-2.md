# Hands-on ECR-02 : Jenkins Pipeline to Push Docker Images to ECR

Purpose of the this hands-on training is to teach the students how to build Jenkins pipeline to create Docker image and push the image to AWS Elastic Container Registry (ECR) on Amazon Linux 2 EC2 instance.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- create and configure AWS ECR from the AWS Management Console.

- configure Jenkins Server with Git, Docker, AWS CLI on Amazon Linux 2 EC2 instance using Cloudformation Service.

- demonstrate how to build a docker image with Dockerfile.

- build Jenkins pipelines with Jenkinsfile.

- integrate Jenkins pipelines with GitHub using Webhook.

- configure Jenkins Pipeline to build a NodeJS project.

- use Docker commands effectively to tag, push, and pull images to/from ECR.

- create repositories on ECR from the AWS Management Console.

- delete images and repositories on ECR from the AWS CLI.

## Outline

- Part 1 - Launching a Jenkins Server Configured for ECR Management

- Part 2 - Prepare the Image Repository on ECR and Project Repository on GitHub with Webhook

- Part 3 - Creating Jenkins Pipeline for the Project with GitHub Webhook

- Part 4 - Cleaning up the Image Repository on AWS ECR

## Part 1 - Launching a Jenkins Server Configured for ECR Management

- Launch a pre-configured `Clarusway Jenkins Server` from the AMI of Clarusway (ami-08857fc3e51ff205e) running on Amazon Linux 2, allowing SSH (port 22) and HTTP (ports 80, 8080) connections using the [Clarusway Jenkins Server on Docker Cloudformation Template Configured to Work with ECR](./clarusway-jenkins-with-git-docker-ecr-cfn.yml). 

- Clarusway Jenkins Server is configured with admin user `call-jenkins` and password `Call-jenkins1234`.


## Part 2 - Prepare the Image Repository on ECR and Project Repository on GitHub with Webhook

### Step-1: Prepare the Image Repository on ECR

- Create a docker image repository `` on AWS ECR from Management Console.

- Create a public project repository `todo-app-node-project` on your own GitHub account.

### Step-2: Prepare Project Repository on instance

- Connect to the "Jenkins server" instance with ssh and get "sudo privileges"

```bash
ssh -i .ssh/xxxxx.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
sudo su
```

- Clone the `todo-app-node-project` repository on  your instance.

```bash
git clone https://github.com/awsdevopsteam/todo-app-node-project.git
```

### Step-3: Download the project and transfer to the project repository.

- Download the sample project `to-do-app-nodejs.tar` file from the GitHub Repo on your instance. 
  
```bash

wget https://github.com/awsdevopsteam/jenkins-first-project/raw/master/to-do-app-nodejs.tar
```
- Extract the `to-do-app-nodejs.tar` file 

```bash
tar -xvf to-do-app-nodejs.tar

```

- Check the files an folder. You will see `to-do-app-nodejs.tar`, `to-do-app-nodejs` and `todo-app-node-project`

- Copy the files from `to-do-app-nodejs` to `todo-app-node-project`

```bash
cp -R to-do-app-nodejs/* todo-app-node-project/

```

### Step-4: Create Dockerfile in project repo.

- Enter the `todo-app-node-project/` and check the files. Then create a Docker file via `vi` editor.

```bash
cd todo-app-node-project/
ls
vi Dockerfile

Press "i" to edit 
```

- Paste  the following content within a Dockerfile which will be located in `todo-app-node-project` repository.

```dockerfile
FROM node:12-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "/app/src/index.js"]
```
- Press "ESC" and ":wq " to save.

- Commit and push the local changes to update the remote repo on GitHub.

```bash
git add .
git commit -m 'added todo app'
git push
```
- Go the github and check the changes

### Step-5: Create Token

- Add token to the github. So, go to your github Account Profile  on right of the top >>>> Settings>>>>Developer Settings>>>>>>>>Personal access tokens >>>>>> Generate new token

- Go to the >>>>>> todo-app-node-project/.git and open Git config file.

```bash
cd .git
vi config

Add "token" after "//" in the "url" part . And also paste "@" at the and of the token.
  "url = https://<yourtoken@>github.com/awsdevopsteam/todo-app-node-project.git

```

### Step-6: Create Webhook 

- Go to the `todo-app-node-project` repository page and click on `Settings`.

- Click on the `Webhooks` on the left hand menu, and then click on `Add webhook`.

- Copy the Jenkins URL from the AWS Management Console, paste it into `Payload URL` field, add `/github-webhook/` at the end of URL, and click on `Add webhook`.

```text
http://ec2-54-144-151-76.compute-1.amazonaws.com:8080/github-webhook/
```

## Part 3 - Creating Jenkins Pipeline for the Project with GitHub Webhook

### Step-1: Github process

- Go to the Jenkins dashboard and click on `New Item` to create a pipeline.

- Enter `todo-app-pipeline` then select `Pipeline` and click `OK`.

- Enter `To Do App pipeline configured with Jenkinsfile and GitHub Webhook` in the description field.

- Put a checkmark on `GitHub Project` under `General` section, enter URL of the project repository.

```text
https://github.com/xxxxxxxx/todo-app-node-project.git
```

- Put a checkmark on `GitHub hook trigger for GITScm polling` under `Build Triggers` section.

- Go to the `Pipeline` section, and select `Pipeline script from SCM` in the `Definition` field.

- Select `Git` in the `SCM` field.

- Enter URL of the project repository, and let others be default.

```text
https://github.com/xxxxxxxxxxx/todo-app-node-project.git
```

- Click `apply` and `save`. Note that the script `Jenkinsfile` should be placed under root folder of repo.

### Step-2: Jenkins instance Process

- Go to the Jenkins instance (todo-app-node-project/ directory)to create `Jenkinsfile`
```bash
cd todo-app-node-project/
ls
vi Jenkinsfile

Press "i" to edit 
```

- Create a `Jenkinsfile` within the `todo-app-node-project` repo with following pipeline script. 

```groovy

pipeline {
    agent { label "master" }
    environment {
        ECR_REGISTRY = "<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com"
        APP_REPO_NAME= "clarusway-repo/todo-app"
    }
    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build --force-rm -t "$ECR_REGISTRY/$APP_REPO_NAME:latest" .'
                sh 'docker image ls'
            }
        }
        stage('Push Image to ECR Repo') {
            steps {
                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh 'docker push "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }
    }
    post {
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
        }
    }
}

```

- Press "ESC" and ":wq " to save.

- Commit and push the local changes to update the remote repo on GitHub.

```bash
git add .
git commit -m 'added Jenkinsfile'
git push
```

### Step-3: Jenkins Build Process

- Go to the Jenkins project page and click `Build Now`.The job has to be executed manually one time in order for the push trigger and the git repo to be registered.

### Step-4: Make change to trigger Jenkins

- Now, to trigger an automated build on Jenkins Server, we need to change code in the repo. For example, in the `src/static/js/app.js` file, update line 56 of `<p className="text-center">No items yet! Add one above!</p>` with following new text.

```html
vi src/static/js/app.js
 <p className="text-center">You have no todo task yet! Go ahead and add one!</p>
```

- Commit and push the change to the remote repo on GitHub.

```bash
git add .
git commit -m 'updated app.js'
git push
```
-if you wan to manually run 

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com
```

- Then run the image

```bash
docker run --name todo -dp 80:3000 <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/clarusway-repo/todo-app:latest
```
- Delete the container 

```bash
docker container stop todo
docker container rm todo
```


### Step 5 Add Deploy stage 
- To show the newly deployed app, first we change the node script. And then  push the changes to create new image in ECR. So when we add deploy stage to the Jenkins file and push it, Jenkins automatically deploy newly created image. 

```html
vi src/static/js/app.js
 <p className="text-center">You have no todo task yet! Go ahead and add one!</p>
```

- Commit and push the change to the remote repo on GitHub.

```bash
git add .
git commit -m 'prep for deploy stage'
git push
```
- obser the Jenkins to finish process

- Go to the Jenkins instance (todo-app-node-project/ directory)to create `Jenkinsfile`
```bash
cd todo-app-node-project/
ls
vi Jenkinsfile

Press "i" to edit 
```

- Change  a `Jenkinsfile` within the `todo-app-node-project` repo with following pipeline script. 

- First press "dG" to delete all

```groovy
  pipeline {
    agent { label "master" }
    environment {
        ECR_REGISTRY = "<aws_account_id>.ecr.us-east-1.amazonaws.com"
        APP_REPO_NAME= "clarusway-repo/todo-app"
    }
    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build --force-rm -t "$ECR_REGISTRY/$APP_REPO_NAME:latest" .'
                sh 'docker image ls'
            }
        }
        stage('Push Image to ECR Repo') {
            steps {
                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh 'docker push "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }
        stage('Deploy') {
            steps {
                sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$ECR_REGISTRY"'
                sh 'docker pull "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
                sh 'docker run --name todo -dp 80:3000 "$ECR_REGISTRY/$APP_REPO_NAME:latest"'
            }
        }

    }
    post {
        always {
            echo 'Deleting all local images'
            sh 'docker image prune -af'
        }
    }
}
```

- Press "ESC" and ":wq " to save.

- Commit and push the local changes to update the remote repo on GitHub.

```bash
git add .
git commit -m 'added Jenkinsfile'
git push
```

### Step 6 Make change to trigger again 

- Change the script to make trigger.

```html
vi src/static/js/app.js
 <p className="text-center">You have no todo task yet! Go ahead and add one!</p>
```

- Commit and push the change to the remote repo on GitHub.

```bash
git add .
git commit -m 'updated app.js'
git push
```

- Observe the new built triggered with `git push` command under `Build History` on the Jenkins project page.

- Explain the built results, and show the output from the shell.

- Go to Jenkins Server instance with SSH. Add `sh 'docker ps -q --filter "name=todo" | grep -q . && docker stop todo && docker rm -fv todo'"` command  before "sh `docker run.......`" command  to the `Deploy` Stage of the the Jenkinsfile 

```groovy
 
                sh 'docker ps -q --filter "name=todo" | grep -q . && docker stop todo && docker rm -fv todo'
 
```
- Show the result.

## Part 4 - Cleaning up the Image Repository on AWS ECR

- If necessary, authenticate the Docker CLI to your default `ECR registry`.

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com
```

- Delete Docker image from `clarusway-repo/todo-app` ECR repository from AWS CLI.

```bash
aws ecr batch-delete-image \
      --repository-name clarusway-repo/todo-app \
      --image-ids imageTag=latest \
      --region us-east-1
```

- Delete the ECR repository `clarusway-repo/todo-app` from AWS CLI.

```bash
aws ecr delete-repository \
      --repository-name clarusway-repo/todo-app \
      --force \
      --region us-east-1
```

