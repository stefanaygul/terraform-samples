I created 2 structures the first one with Cloudfront and ECS solution and the second one with EC2(compute) solution. I added the terraform files for ECS and Cloudfront solution but i added 2 architecture design and explanation on that repo.

# 1. High Available EC2 Structure with Multi-AZ Redis and RDS

The following figure provides another look at that classic web application architecture and how it can leverage the AWS Cloud computing infrastructure.

<img width="786" alt="Screenshot 2023-09-17 at 18 55 32" src="https://github.com/stefanaygul/terraform-samples/assets/30243843/abf40e81-630f-432c-8ffe-31a79cd017fa">


# Virtual Private Network (VPC)

Firstly, create 3 public subnets for frontend, database and backend applications and attached an Internet Gateway to VPC.
Than, configure route tables for the public subnets to route traffic to the Internet Gateway.

After that, create 3 private subnets for frontend, database and backend applications. I did not associate these subnets with a Network ACL.
Than, configure route tables for the private subnets to route traffic to NAT Gateways.

Finally, created 3 NAT Gateways in public subnets and associated an Elastic IP address with each NAT Gateway. Update the route tables of the private subnets to route outbound traffic to the respective NAT Gateways.

**DNS services with Amazon Route 53**  - Provides DNS services to simplify domain management.

**Amazon CloudFront – Edge caches high** - Volume content to decrease the latency to customers.

**Amazon CloudFront with AWS WAF** – Filters malicious traffic, including cross site scripting (XSS) and SQL injection via customer-defined rules.

**Elastic Load Balancing (ELB)** – Enabled to spread load across multiple Availability Zones and Amazon EC2 Auto Scaling groups for redundancy and decoupling of services.

**DDoS protection with AWS Shield** – Safeguards your infrastructure against the most common network and transport layer DDoS attacks automatically.

**Security groups** – Moves security to the instance to provide a stateful, host-level firewall for both web and application servers.

**Amazon ElastiCache** – Provides caching services with Redis to remove load from the app and database, and lower latency for frequent requests.

**Amazon Relational Database Service (Amazon RDS)** – Created a highly available, multi-AZ database architecture

**Amazon Simple Storage Service (Amazon S3)** – Enables simple HTTP-based object storage for backups and static assets like images and video.

# Terraform Structure

The Modules part is specifically for each AWS service. For example, the VPC module has all the behavior which you can implement manually on AWS Console. Also that directory will be better to use for environment specific implementations. 

You can create dev, stage and Prod directories and have specific implementation for each environment, you only need to write your configurations and variables for each env. For example, you want to implement a db.t3.micro db instance for dev and db.t3.large instance for stage so only you need to change specific parameters for each environment. You can see an example below. I just created for that case dev directory for that case.

Also, i stored terraform state files under the S3 bucket ( ninja-terraform-state) that information is important because if you lost your terraform configuration also the state will be under that repo and you can download that state file and continue implementation without any error.


# 2. High Available ECS and Cloudfront Structure with Multi-AZ Redis and RDS
# Terraform Implementation

1. Clone the entr-infra repo with below command:
$ git clone git@github.com-stefanaygul:terraform-samples.git

2. As i mentioned above you will see dev, stage and prod environments, if you want to add any configuration for dev, you will open dev directory and then add your configuration to dev.tf or you can create a new file with each name and you will give the variable names and configuration settings. 

3. After configuration changes we need to do the terraform steps.

Go under the related environment directory with $ cd dev/  command and then run below commands:

    $ terraform init
	$ terraform plan
	$ terraform apply

terraform init command will initialize the version and providers which we pointed to in provider.tf. Then, with the terraform plan command you will see what will change after you changed the configuration and if everything is okay you can run the terraform apply command.


Manual Steps on AWS

- IAM(Creating user, adding role and groups)
     Managing, users, groups and roles manually better and faster than terraform and we can discuss about that topis deeply. 
- S3 bucket creation and DynamoDb settings except cloudfront
     Also, i created **ninja-terraform-state** bucket to store state file and **terraform_state_lock** table on Dynamodb to lock the state file for deletion by mistake.
- Route 53 (Domain settings)
     you should create Hosted Zone like example.com


There are 2 services implemented on AWS and one of them is frontend and the other one is backend api. The frontend part is implemented with S3, Cloudfront and Route 53 architecture and you can see the design below. 

<img width="649" alt="Screenshot 2023-09-17 at 18 24 58" src="https://github.com/stefanaygul/terraform-samples/assets/30243843/c4e479ed-f2c0-4932-b7dd-cffdec145f69">


And the backend part is implemented with ECS Fargate and has a backend container, task definition and routed with application load balancer to Route53. Also, you can see the architecture of the backend project below.

<img width="645" alt="Screenshot 2023-09-17 at 18 25 15" src="https://github.com/stefanaygul/terraform-samples/assets/30243843/123d08f6-d56c-4afd-8277-3a2399218d0d">


