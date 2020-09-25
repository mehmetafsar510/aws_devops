# Hands-on EC2-06 : Working with Application Load Balancer (ALB) using a Launch Template

Purpose of this hands-on training is to learn Application Load Balancer (ALB) working process. Especially, we’ll cover the details of the AWS solution suite and walk through how to set up a basic ALB.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- create security group.

- create a target group.

- create Application Load Balancer.

- attach target group to ALB.

## Outline

- Part 1 - Creating a Security Group

- Part 2 - Launch Instances with Launch Template

- Part 3 - Creating a Target Group

- Part 4 - Creating Application Load Balancer together with Target Group



## Part 1 - Creating a Security Group

1. Open the Amazon EC2 console at https://console.aws.amazon.com/ec2/.

2. Choose Security Groups on the left-hand menu,

3. Click the "Create Security Group" tab.

```text
Security Group Name  : ALBSecGroup
Description         : ALB Security Group
VPC                 : Default VPC
Inbound Rules:
    - Type: SSH----> Source: Anywhere
    - Type: HTTP ---> Source: Anywhere
Outbound Rules: Keep it as it is
Tag:
    - Key   : Name
      Value : ALB SEC Group
```

4. Click "Create Security Group" button.

## Part 2 - Launch Two Instance Using the Launch Template

### Step 1 - Launch Template Configuration

5 Launch Template Name

```text
Launch template name            : ALBtemplate
Template version description    : ALBtemplate
```

6. Amazon Machine Image (AMI)

```text
Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type, (us-east-1)
```

7. Instance Type

```text
t2.micro
```

8. Key Pair

```text
Please select your key pair (pem key) that is created before
Example: clarusway.pem
```

9. Network settings

```text
Network Platform : Virtual Private Cloud (VPC)
```

10. Security groups

```text
Please select security group named ALBSecGroup
```

11. Storage (volumes)

```text
keep it as default (Volume 1 (AMI Root) (8 GiB, EBS, General purpose SSD (gp2)))
```

12. Resource tags

```text
Key             : Name
Value           : ALBInstance
Resource type   : Instance
```

13. Network interfaces

```text
Keep it as it is
```
14. Within Advanced details section, we will just use user data settings. Please paste the script below into the `user data` field.


#!/bin/bash

#update os
yum update -y
#install apache server
yum install -y httpd
# get private ip address of ec2 instance using instance metadata
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& PRIVATE_IP=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4`
# get public ip address of ec2 instance using instance metadata
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& PUBLIC_IP=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4` 
# get date and time of server
DATE_TIME=`date`
# set all permissions
chmod -R 777 /var/www/html
cd /var/www/html
wget https://raw.githubusercontent.com/awsdevopsteam/ngniex/master/ryu.jpg
# create a custom index.html file
echo "<html>
<head>
    <title> Congratulations! You have created an instance from Launch Template</title>
</head>
<body>
    <h1>This web server is launched from launch template by AWSDevOps Team</h1>
    <p>This instance is created at <b>$DATE_TIME</b></p>
    <p>Private IP address of this instance is <b>$PRIVATE_IP</b></p>
    <p>Public IP address of this instance is <b>$PUBLIC_IP</b></p>
    <p><img src="ryu.jpg" alt="Oz Hakiki Cikolata Deryasi"</b></p>
</body>
</html>" > /var/www/html/index.html
# start apache server
systemctl start httpd
systemctl enable httpd


### Step-2: Launch Two Instances Using the Launch Template

15. Go to Launch Templates section on left-hand menu on AWS EC2 Dashboard.

16. Select the launch template named `ALBtemplate`.

17. Click `Actions >> Launch instance` from template interface.

```text
Number of instances  : 3
```

18. Click "Launch Instance from Template"

19. Go to the instance page from the left-hand menu . Show the differences of newly created instances on the browser (IP and dates) via entering public IP addresses.

## Part 3 - Create a target group

20. Go to `Target Groups` section under the Load Balancing part on left-hand side and click it.

21. Click `Create Target Group` button.

22. Basic configuration.

```text
Choose a target type    : Instances
Give Target Groups Name : MyFirstTargetGroup
Protocol                : HTTP
Port                    : 80
VPC                     : Default
```

23. Health checks

```text
Health check protocol   : HTTP
Health check path       : /
```

24. Advance Health check settings.

```text
Port                    : Traffic port
Healthy treshold        : 5
Unhealthy treshold      : 2
Timeout                 : 5 seconds
Interval                : 10 seconds
Succes codes            : 200
```

25. Tags

```text
Key                     : Name
Value                   : Target
```

26. Click next.

27. Select two instances that is created from Launch Template before and add to them to the target group.

```text
Ports for the selected instances : 80
```

28. Click `Include as pending below` button.

29. Show that two instances are added to the target group.

30. Click `Create target group` button.

## Part 4 - Creating Application Load Balancer together with Target Group

31. Go to the Load Balancing section on left-hand menu and click `Load Balancers`.

32. Tap `Create Load Balancer` button.

33. Click `Create` button inside the `Application Load Balancer` section.

### Step 1 - Configure Load Balancer

```text
Name            : MyFirstALB

Listeners       : A listener is a process that checks for connection requests,
using the protocol and port that you configured.

Load Balancer Protocol      : HTTP
Load Balancer Port          : 80
Availability Zones          : Choose all AZ's

Add-on services             : Keep it as it is
Tags                        :
    - Key   : Name
    - Value : MyFirstALB
```

### Step 2 - Configure Security Settings

```text
You'll see the warning page;

!!! Improve your load balancer security. Your load balancer is not using any secure listener.!!!

This comes because of we didn't choose https for listener ports. We can leave it as it is and click the Next button
```

### Step 3 - Configure Security Groups

34. Select an existing group.

```text
Name :  ALBSecGroup
```

35. Click Next: `Configure Routing`

### Step 4 - Configure Routing

```text
Target group        : Existing target group
Name                : Target
```

When we select target group it is not necessary to adjust the rest of the settings, since we set all parts while creating Target Group

36. Click Next: `Register Targets`

```text
They have also determined by target group named Turgut too. 
```

37. Click next button

38. Review if everything is ok, and then click the `Create` button

```text
Successfully created load balancer!
```

39. Click `Close` tab

40. Please wait for `State` to turn into `active` from `provisioning`.

41. Show on the browser that how the requests are routed to different instance with the help of the ALB.

```text

42. Select Load Balancer named MyFirstALB

43. Copy the ALB's DNS name. It should be something like `MyFirstALB-1185163036.us-east-1.elb.amazonaws.com`

44. Paste is on browser and refresh it

45. Show the changing Public and Private IP addresses and time that the instances was created


46. Explain the monitoring dashboard of ALB.

47. Stop one of the instance from teminal

   sudo systemctl stop httpd

48. Show the health check status of instance from target group

49. Then start the httpd and show the healthcheck status: health

   sudo systemctl start httpd

50. Show Attributes----> Load balancing algorithm------>Round robin

51. Change the "Roud robin" to "Least outstanding requests"
