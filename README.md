# VProfile Project Infrastructure

This repository contains the Terraform configuration files to set up the infrastructure for the VProfile project. The infrastructure includes an Elastic Beanstalk environment, RDS instance, ElastiCache cluster, and RabbitMQ broker.

## Prerequisites

- Terraform installed on your local machine
- AWS CLI configured with appropriate credentials
- An S3 bucket for storing the Terraform state

## Setup Instructions

### 1. Clone the Repository

```sh
git clone https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
```

### 2. Configure AWS Credentials

Update the provider configuration in [`main.tf`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%5D "e:\Terraform\122 Vprofile PAAS and SAAS\infra\main.tf") to point to your AWS credentials file if necessary.

### 3. Initialize Terraform

```sh
terraform init
```

### 4. Apply the Terraform Configuration

```sh
terraform apply
```

### 5. Update Application Properties

After the Elastic Beanstalk environment is active, update the [`application.properties`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5CREADME.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2FREADME.md%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A5%2C%22character%22%3A29%7D%7D%2C%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5CREADME.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2FREADME.md%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A5%2C%22character%22%3A29%7D%7D%2C%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A287%2C%22character%22%3A26%7D%7D%5D%5D "Go to definition") file with the credentials and endpoints for RDS, Memcached, and RabbitMQ.

```sh
cd src/main/resources
nano application.properties
```

Update the following properties:

- **RabbitMQ**
  ```properties
  rabbitmq.username = "rabbit"
  rabbitmq.password = (found in key folder)
  rabbitmq.address = (can be found in console Amazon MQ endpoint)
  ```

- **JDBC**
  ```properties
  jdbc.username = admin
  jdbc.password = (found in key folder)
  jdbc

.url

 = (endpoint found in console RDS)
  ```

- **Memcached**
  ```properties
  memcached.host = (in console in Amazon ElastiCache > Memcached caches)
  ```

### 6. Build and Deploy the Application

1. Verify Maven installation:
   ```sh
   mvn -version
   ```

2. Build the project:
   ```sh
   mvn install
   ```

3. The WAR file will be located in the [`target/`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5CREADME.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2FREADME.md%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A35%2C%22character%22%3A15%7D%7D%5D%5D "Go to definition") directory. Upload and deploy this WAR file to Elastic Beanstalk via the AWS Management Console.

### 7. Configure DNS

Use the Elastic Beanstalk domain to create a CNAME record pointing to your custom domain.

### 8. S3 Backend for Terraform State

If you haven't already, create an S3 bucket and update the [`backend`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5CREADME.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2FREADME.md%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A44%2C%22character%22%3A12%7D%7D%2C%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A15%2C%22character%22%3A40%7D%7D%5D%5D "Go to definition") configuration in the Terraform provider to use this bucket.

### 9. Lifecycle Ignore Changes

The configuration includes [`lifecycle_ignore_changes`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5CREADME.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2FREADME.md%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A52%2C%22character%22%3A6%7D%7D%5D%5D "Go to definition") for MQ and Beanstalk to prevent unnecessary updates. Remove these settings if you need to change configurations.

## Resources

- **Elastic Beanstalk Application**: [`aws_elastic_beanstalk_application.vprofile_app`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A285%2C%22character%22%3A10%7D%7D%5D%5D "Go to definition")
- **Elastic Beanstalk Environment**: [`aws_elastic_beanstalk_environment.vprofile_app_prod`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A291%2C%22character%22%3A10%7D%7D%5D%5D "Go to definition")
- **RDS Instance**: [`aws_db_instance.vprofile-rds-mysql`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A66%2C%22character%22%3A10%7D%7D%5D%5D "Go to definition")
- **ElastiCache Cluster**: [`aws_elasticache_cluster.vprofile-elasticache-svc`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A143%2C%22character%22%3A10%7D%7D%5D%5D "Go to definition")
- **RabbitMQ Broker**: [`aws_mq_broker.vprofile-rmq`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A165%2C%22character%22%3A10%7D%7D%5D%5D "Go to definition")

## Security Groups

- **Backend Security Group**: [`aws_security_group.vprofile-backend-SG`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A15%2C%22character%22%3A10%7D%7D%5D%5D "Go to definition")
- **MySQL Client Security Group**: [`aws_security_group.mysql-client-sg`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A15%2C%22character%22%3A10%7D%7D%5D%5D "Go to definition")

## IAM Roles

- **Elastic Beanstalk Service Role**: [`aws_iam_role.elasticbeanstalk_service_role`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A79%2C%22character%22%3A31%7D%7D%5D%5D "Go to definition")
- **VProfile Bean Role**: [`aws_iam_role.vprofile_bean_role`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A79%2C%22character%22%3A31%7D%7D%5D%5D "Go to definition")

## Notes

- The [`sql_executor`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5CREADME.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2FREADME.md%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A0%2C%22character%22%3A7%7D%7D%2C%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5CREADME.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2FREADME.md%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A0%2C%22character%22%3A7%7D%7D%2C%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A520%2C%22character%22%3A27%7D%7D%5D%5D "Go to definition") and [`resource "aws_security_group_rule" "allow_eb_to_backend"`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5CREADME.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2FREADME.md%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A0%2C%22character%22%3A24%7D%7D%2C%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5CREADME.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2FREADME.md%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A0%2C%22character%22%3A24%7D%7D%2C%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5Cinfra%5C%5Cmain.tf%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2Finfra%2Fmain.tf%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2Finfra%2Fmain.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A5%2C%22character%22%3A0%7D%7D%5D%5D "Go to definition") are commented out to avoid issues when running together with other resources.
- Ensure to update the credentials path in the provider if using AWS credentials to run Terraform.

## Update Log

- **2024-08-19**: Used S3 for the backend of Terraform state on providers. Added [`lifecycle_ignore_changes`](command:_github.copilot.openSymbolFromReferences?%5B%22%22%2C%5B%7B%22uri%22%3A%7B%22%24mid%22%3A1%2C%22fsPath%22%3A%22e%3A%5C%5CTerraform%5C%5C122%20Vprofile%20PAAS%20and%20SAAS%5C%5CREADME.md%22%2C%22_sep%22%3A1%2C%22external%22%3A%22file%3A%2F%2F%2Fe%253A%2FTerraform%2F122%2520Vprofile%2520PAAS%2520and%2520SAAS%2FREADME.md%22%2C%22path%22%3A%22%2FE%3A%2FTerraform%2F122%20Vprofile%20PAAS%20and%20SAAS%2FREADME.md%22%2C%22scheme%22%3A%22file%22%7D%2C%22pos%22%3A%7B%22line%22%3A52%2C%22character%22%3A6%7D%7D%5D%5D "Go to definition") for MQ and Beanstalk.

---

For any issues or contributions, please open an issue or submit a pull request on the [GitHub repository](https://github.com/hkhcoder/vprofile-project).
```

This README provides a comprehensive guide to setting up and deploying the VProfile project infrastructure using Terraform. It includes all necessary steps, configurations, and resource details.