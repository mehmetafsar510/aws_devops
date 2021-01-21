# Web App - Single Server to Elastic Evolution

 You are going to evolve the architecture of a popular web application wordpress
The architecture will start with a manually built single instance, running the application and database
over the stages of the demo you will evolve this until its a scalable and resilient architecture using Aws Cloudformation template.

- [WepApp Template]()


![Architecture](pic250.png)

The demo consists of 7 stages, each implementing additional components of the architecture  

- Stage 1 - Setup the environment and manually build wordpress  
- Stage 2 - Automate the build using a Launch Template  
- Stage 3 - Split out the DB into RDS and Update the LT 
- Stage 4 - Split out the WP filesystem into EFS and Update the LT
- Stage 5 - Enable elasticity via a ASG & ALB and fix wordpress (hardcoded WPHOME)



