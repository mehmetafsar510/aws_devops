# Hands-on CW-01 : Setting Cloudwatch Alarm Events, and Logging

Purpose of the this hands-on training is to create Dashboard, Cloudwatch Alarm, configure Events option and set Logging up.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- create Cloudwatch Dashboard.

- settings Cloudwatch metrics.

- create an Alarm.

- create an Events.

- configure Logging.


## Outline

- Part 1 - Prep - Launching an Instance

- Part 2 - Creating a Cloudwatch dashboard

- Part 3 - Creating an Alarm

- Part 4 - Creating an Events

- Part 5 - Configure Logging

## Part 1 - Prep - Launching an Instance

STEP 1 : Create a EC2

-Go to EC2 menu using AWS console

- Launch an Instance
- Configuration of instance.

```text
AMI             : Amazon Linux 2
Instance Type   : t2.micro
Configure Instance Details:
  - Monitoring ---> Chech "Enable CloudWatch detailed monitoring"
Tag             :
    Key         : Name
    Value       : Cloudwatch_Instance
Security Group ---> Allows ssh, http, https to anywhere
```
- Set user data.

```bash
#! /bin/bash
yum update -y
amazon-linux-extras install nginx1.12
chkconfig nginx on
cd /usr/share/nginx/html
chmod o+w /usr/share/nginx/html
rm index.html
wget https://raw.githubusercontent.com/awsdevopsteam/route-53/master/index.html
wget https://raw.githubusercontent.com/awsdevopsteam/route-53/master/ken.jpg
service nginx start
```

## Part 2 - Creating a Cloudwatch dashboard

STEP 1: Create Dashboard

- Go to the Cloudwatch Service from AWS console.

- Select Dashboards from left hand pane

- Click "Create Dashboard"
```
Dashboard Name: Clarusway_Dashboard
```

- Select a widget type to configure as "Line"  ---> Next

- Select Metrics  ----> Tap configure button

- Select "EC2" as a metrics

- Select "Per-instance" metrics

- Select "Cloudwatch_Instance", "CPUUtilization"  ---> Click "create widget"


STEP 2: Upload Stress tool on EC2

- Connect to the EC2 via ssh

- Upload Stress tool and run it

```bash
sudo amazon-linux-extras install epel -y
sudo yum install -y stress
stress --cpu 80 --timeout 20000   #(optionally using 3000 for timeout)
```

- It takes a while to install stress

- Show that EC2 CPUUtilization Metrics increased

- go to terminal and stop the stress tool using "Ctrl+C" command


## Part 3 - Create an Alarm.

- Select Alarms on left hand pane

- click "Create Alarm"

- Click "Select metric"

- Select EC2 ---> Per-Instance Metrics ---> "CPUUtilization" ---> Select metric
```bash
Metric      : change "period" to 1 minute and keep remaining as default
Conditions  : 
  - Treshold Type                 : Static
  - Whenever CPUUtilization is... : Greater
  - than...                       : 60
```
- click next
```bash
Notification:
  - Alarm state trigger : In alarm
  - Select an SNS topic : 
    - Create new topic
      - Create a new topic… : Clarus-alarm
      - Email endpoints that will receive the notification…
: <your email adress>
    - create topic

EC2 action
  - Alarm state trigger
    - In alarm ---> Select "Stop Instance"
```

- click next

- Alarm Name  : My First Cloudwatch Alarm
  Description : My First Cloudwatch Alarm

- click next --- > review and click create alarm

- go to email box and confirm the e-mail sent by AWS Cloudwatch service

- go to the terminal and connect EC2 instance via ssh

- start the stress tool:
```bash
 stress --cpu 80 --timeout 20000
```
- Go to dashboard and check the EC2 metrics

- you will receive a alarm message to your email and this message trigger to stop your EC2 Instance.

- go to EC2 instance list and show the stopped instance

- restart this instance.


### Part 4 - Creating an Events

STEP 1 : Create a EC2 Instance

-Go to EC2 menu using AWS console

- Launch an Instance
- Configuration of instance.

```text
AMI             : Amazon Linux 2
Instance Type   : t2.micro
Tag             :
    Key         : Name
    Value       : Cloudwatch_Log
Security Group ---> Allows all trafic --->  anywhere
```
- Set user data.

```bash
#! /bin/bash
yum update -y
amazon-linux-extras install nginx1.12
chkconfig nginx on
cd /usr/share/nginx/html
chmod o+w /usr/share/nginx/html
rm index.html
wget https://raw.githubusercontent.com/awsdevopsteam/route-53/master/index.html
wget https://raw.githubusercontent.com/awsdevopsteam/route-53/master/ken.jpg
service nginx start
```

STEP 2 : Create IAM role

- Go to IAM role on AWS console

- Click Roles on left hand pane

- click create role

- select EC2 ---> click next permission

- select "CloudWatchLogsFullAccess"  ---> Next

- Add tags ---> Next

- Review
	- Role Name :Claruscloudwatchlog  

- click create role

- Go to instance named "Cloudwatch_Log" ---> Actions ---> Instance settings ---> Attach/Replace IAM role ----> Attach "CloudWatchLogsFullAccess" role ---> Apply

STEP 3:  Install and Configure the CloudWatch Logs Agent

- Go to the terminal and connect to the Instance named "Cloudwatch_Log"

- install cloudwatch log agent with following command:
```bash
sudo yum install -y awslogs
sudo systemctl start awslogsd
sudo systemctl enable awslogsd.service
```
- go to the Cloudwatch menu and select Log groups on left hand pane

- click the created log group named "/var/log/messages" ---> show the newly created "log streams"


STEP 4: Configure Nginx logs

- go to the terminal and connect to the EC2 Instance named "Cloudwatch_Log" with ssh

- go to the "awslogs" folder using "cd /etc/awslogs/" command

- use the root account
```bash
sudo su
```

- open the file named awslogs.conf
```bash
vi awslogs.conf
```

- at the bottom of the page you'll see the following comments:
```bash
[/var/log/messages]
datetime_format = %b %d %H:%M:%S
file = /var/log/messages
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/messages
```

- press "I" and paste the following command right after command seen above: 


```bash

[/var/log/nginx/access.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/nginx/access.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = AccessLog

[/var/log/nginx/error.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/nginx/error.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = ErrorLog
```

- save the file and close
```bash
:wq
```

- to activate the new configuraion, stop and start the "awslogsd".

```
sudo systemctl stop awslogsd
sudo systemctl start awslogsd
```
- go tot the Cloudwatch logs group again 

- click the created log group named "AccessLog" and "ErrorLog" ---> show the newly created "log streams"






