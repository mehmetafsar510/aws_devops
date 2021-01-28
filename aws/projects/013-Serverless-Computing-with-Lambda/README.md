# Serverless Computing with Lambda

You will create a website hosted on AWS S3 using AWS Lambda and Amazon API Gateway to add dynamic functionality to the site using AWS Cloudformation Service. The topics for this hands-on session will be AWS Lambda, function as a service (FaaS).

[Serverless Computing with Lambda-Template](https://github.com/mehmetafsar510/aws_devops/blob/master/aws/projects/013-Serverless-Computing-with-Lambda/Serverless-Computing-with-lambda.yml)(During upload this template, you have to upload static web site and lambda function(RomanNumbers) to s3 bucket with help of [upload-script.sh](https://github.com/mehmetafsar510/aws_devops/blob/master/aws/projects/013-Serverless-Computing-with-Lambda/upload-script.sh). Otherwise you will take rollback.)

![Steps](pic(245).png)

# What is Serverless ?

A computing model where the existence of servers are hidden from developers. Within AWS eco-system Lambda is not the only serverless service. For the purpose of these hands-on we will look at S3, Lambda, and API Gateway to produce a functional website.

- __Storage__ - S3
- __Compute__ - Lambda
- __Database__ - DynamoDB, ElasticCache
- __API Proxy__ - API Gateway
- __Analytics__ - AWS Kinesis
- __Messaging & Queues__ - AWS SNS, SQS
- __State Management__ - AWS Step Functions
- __Diagnostics__ - AWS X-Ray

# What Services these hands-on are covering?

- __S3 - Static Web hosting:__ Hosting a static website on S3 bucket.
- __Lambda:__ Creating a lambda function, that generates a random number and another function that processes form GET and PUT requests.
- __API Gateway:__ Using API Gateway to expose lambda function to static website hosted on S3 bucket.
