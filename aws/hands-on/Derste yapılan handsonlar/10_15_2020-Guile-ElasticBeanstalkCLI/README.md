# Hands-on EB-02 : Introduction to AWS Elastic Beanstalk CLI

Purpose of this hands-on training is to give the students basic knowledge of installing and configuring the AWS Elastic Beanstalk CLI and how to deploy applications using AWS Elastic Beanstalk CLI.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- install and configure AWS Elastic Beanstalk CLI 

- deploy a sample applications using AWS Elastic Beanstalk CLI

- terminate the environment created for the application using AWSEB CLI.

## Outline

- Part 1 - Create an IAM Role for Elastic Beanstalk

- Part 2 - Install and Configure AWSEB CLI

- Part 3 - Create the Application

- Part 4 - Create the Environment

- Part 5 - Terminate the Environment


## Part 1 - Create an IAM Role for Elastic Beanstalk

- To allow Elastic Beanstalk to create and manage resources onbehalf of us, first we have to create an IAM role.

- Go to `IAM` service on AWS console.

- Click `Roles` >> `Create role`.

- Keep `AWS Services` selected on `Select type of trusted entity`.

- Select `Elastic Beanstalk` selected on `Choose a use case`.

- After selecting `Elastic Beanstalk`, roll the page down and select `Elastic Beanstalk Customizable` and click `Next:Permisions`.

- See the two policies `AWSElasticBeanstalkEnhancedHealth` and `AWSElasticBeanstalkService` and click `Next:Tags`.

- Click `Next:Review` without any input.

- Enter `aws-elastic-beanstalk-service-role` as `Role name` and click `Create role`.


## Part 2 - Install and Configure AWSEC CLI

- Open your terminal.

- Create a folder called `beanstalk`, get into it.

- Copy the sample app files into the `beanstalk` folder.

- Update and upgrade your OS from terminal.

- To install AWSEB CLI, you must have pip (or pip3) installed on your system (Check >> pip -V or pip3 -V). If you don't have, install pip/pip3 package depending on you system first.

- If you have different Python Versions installed, you can create a virtual environment. If you don't, skip this step and jump to next one (`Install AWSEB CLI`).

  * install `python-venv` (command varies depending on your distro)

    $ sudo apt-get install python3-venv     

  * create a virtual environment called `beanstalk`:

    $ python -m venv beanstalk  (or python3 -m venv beanstalk)

  * activate virtual environment

    $ source beanstalk/bin/activate

  * Check virtual environment activated >> $(beanstalk)user@computer

- Install AWSEB CLI

  * $ pip install awsebcli (or pip3 install awsebcli)

- If you have an error about path, use this command to add it to your PATH

  * $ export PATH=~/.local/bin:$PATH

- Check version

  * $ eb --version

- Type `$ eb` and show the awseb cli commands.
  
- If you have AWS credentials configured on your computer, you don't need to configure them again. But if you don't have, you have to set them on the next part, so make your `Access Key` and `Secret Access Key` ready to use.



## Part 3 - Create the Application

- In the `beanstalk` folder run the command below, if you are asked, enter your `Access Key` and `Secret Access Key`.

  $ eb init

  * Select a default region
    1) us-east-1 : US East (N. Virginia)

  * Leave it as default

      Enter Application Name
    (default is "beanstalk"):

  * Yes, Type y

     It appears you are using Python. Is this correct?
  (Y/n):

  * Select `2) Python 3.6 running on 64bit Amazon Linux`, since the app is running on Python 3.6

    Select a platform branch. 
    1) Python 3.7 running on 64bit Amazon Linux 2
    2) Python 3.6 running on 64bit Amazon Linux
    3) Python 3.4 running on 64bit Amazon Linux (Deprecated)
    4) Python 2.7 running on 64bit Amazon Linux (Deprecated)
    5) Python 2.6 running on 64bit Amazon Linux (Deprecated)
    6) Preconfigured Docker - Python 3.4 running on 64bit Debian (Deprecated)
    (default is 1):

  * Yes, Type y

    Cannot setup CodeCommit because there is no Source Control setup, continuing with initialization
    Do you want to set up SSH for your instances?
    (Y/n):

  * Select your keypair

- Go to `Elastic Beanstalk` service on AWS console.

- Click `Applications` on the left hand menu

- Show that the applicaiton is created but doesn't have an environment yet. 

## Part 4 - Create the Environment

- Go back to your terminal.

- In the `beanstalk` folder run the command below.

  $ eb create --vpc.elbpublic --database.instance db.t2.micro --database.engine mysql --elb-type application --service-role aws-elastic-beanstalk-service-role

  * Leave it default

    Enter Environment Name
    (default is beanstalk-dev):

  * Leave it default

    Enter DNS CNAME prefix      
    (default is beanstalk-dev):

  * No, type n

    Would you like to enable Spot Fleet requests for this environment? (y/N):

  * Leave it default

    Enter an RDS DB username (default is "ebroot"):  

  * Type `12345678` as password

    Enter an RDS DB master password:

  * Retype `12345678` to confirm

    Retype password to confirm:

- Environment creation process starts, show that you can monitor events on the terminal.

- Show resources being created.

- Go to `Elastic Beanstalk` service on AWS console.

- Click `Environments` on the left hand menu.
  
- Click `beanstalk-dev` environment. You will see the events on the service window, if the creation process continues.

- Creation process may take a while (apprx. 10 mins).

- After the environment beanstalk-dev launched successfully, you will see the `Health` status `Ok`.

- From the left-hand menu show the app and env menus, talk about them. Click on the tabs like Configuration, Monitoring etc. and explain them. Show the resources being created, show the configuraitons and talk about them.

- Go to EC2 service on AWS console and show the resources (Instances, Load Balancers, ASG's etc.) created by Elastic Beanstalk.

- Go to RDS service on AWS console and show the database created by Elastic Beanstalk.

- Go back to the `Elastic Beanstalk` service, from `beanstalk-dev` environment click the link (Application URL) and show the Web Page. 

- On the web page click `Log in`.

- There are two predefined users, log in for each and make some entries to the app, show that the app and the DB is working properly.

```
  * username: joe
    pw: secret123
  
  * username: anne
    pw: secret123
```

## Part 5 - Terminate the Environment

- Go back to your terminal.

- Type the command below to terminate the environment.

  $ eb terminate

  * The environment "beanstalk-dev" and all associated instances will be terminated.
To confirm, type the environment name:

  * Type the environment name and hit enter.

- Show the resources being terminated from the terminal.

- Go to `Elastic Beanstalk` service on AWS console, show the termination process.

- Wait for a while and show the environment is deleted.

- RDS takes a snapshot during the process above, to avoid extra charges, go to the RDS service on AWS console and delete the snapshot.

- You can optionally delete the beanstalk application.
