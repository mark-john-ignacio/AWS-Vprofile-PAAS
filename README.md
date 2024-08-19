
# VProfile SaaS Infrastructure Project

This Terraform project sets up the infrastructure for the VProfile SaaS application on AWS. It includes various components such as RDS, ElastiCache, Amazon MQ, Elastic Beanstalk, and CloudFront.

## Project Structure

- `data_sources.tf`: Defines data sources for VPC, subnets, AMIs, and other existing resources.
- `main.tf`: Contains the main infrastructure components including security groups, RDS, ElastiCache, Amazon MQ, IAM roles, and Elastic Beanstalk configuration.
- `output.tf`: Defines output variables and creates a local file with endpoint information.
- `provider.tf`: Specifies the required providers and backend configuration.
- `variables.tf`: Declares input variables for the project.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version compatible with AWS provider >= 4.9.0)
- An S3 bucket for Terraform state (specified in `provider.tf`)

## Key Components

1. **RDS MySQL Database**
2. **ElastiCache Memcached Cluster**
3. **Amazon MQ (RabbitMQ)**
4. **Elastic Beanstalk Environment**
5. **CloudFront Distribution**
6. **Various Security Groups and IAM Roles**

## Usage

1. Clone this repository.
2. Update the `variables.tf` file with your AWS access key and secret key (or use environment variables).
3. Initialize Terraform:
   ```
   terraform init
   ```
4. Review the planned changes:
   ```
   terraform plan
   ```
5. Apply the configuration:
   ```
   terraform apply
   ```

## Important Notes

- The project uses a default VPC and its subnets. Ensure these resources exist in your AWS account.
- An existing SSL certificate ARN is used for the Elastic Beanstalk environment and CloudFront distribution. Make sure this certificate exists in your AWS account or update the ARN.
- The project includes commented-out resources for executing SQL scripts. Uncomment and modify as needed.

## Outputs

After applying the Terraform configuration, you can find the following information in the `key/endpoints.txt` file:

- RDS Endpoint and Port
- Memcached Endpoint and Port
- RabbitMQ Endpoint

## Security

- Ensure that the AWS credentials are kept secure and not committed to version control.
- Review and adjust security group rules as per your security requirements.

## Cleanup

To destroy the created resources:

```
terraform destroy
```

**Note:** This will delete all resources created by this Terraform configuration. Use with caution.

## Contributing

Feel free to submit issues or pull requests for any improvements or bug fixes.

## License

[Specify your license here]
