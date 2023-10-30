# AWS Jenkins EC2 Instance Provisioning with Terraform

This README provides a detailed guide for provisioning an AWS EC2 instance for Jenkins using Terraform. It outlines the prerequisites, configuration details, and usage instructions. The Terraform configuration deploys an EC2 instance, sets up a security group for Jenkins, and retrieves the Jenkins URL and initial admin password. 

## Prerequisites

Before using this Terraform configuration, make sure you have the following prerequisites in place:

1. **Terraform Installed:** Ensure you have Terraform installed on your local system. You can download and install Terraform from the official website: [Terraform Downloads](https://www.terraform.io/downloads.html).

2. **AWS Credentials:** Configure your AWS credentials either by setting environment variables or using AWS CLI profiles. These credentials should have the necessary permissions for creating EC2 instances and security groups.

3. **Variables Defined:** Customize the variables required for this configuration. You can define them in a `.tfvars` file or provide them directly when running Terraform.

## Configuration

The main Terraform configuration file, `main.tf`, defines the AWS resources to be provisioned. Here's an overview of the key components:

### AWS Provider Settings

The configuration specifies the AWS provider settings, including the desired region for resource creation.

```hcl
provider "aws" {
  region = var.region
}
```

### EC2 Instance Provisioning

The code provisions an EC2 instance for Jenkins. It specifies details such as the Amazon Machine Image (AMI), instance type, public IP association, key pair, root volume settings, and user data script.

```hcl
resource "aws_instance" "Jenkins" {
  # ...
}
```

The `user_data.sh` script contains commands to set up Jenkins and retrieve the Jenkins URL and initial admin password.

### Security Group Configuration

A security group is defined to control inbound and outbound traffic for the Jenkins instance. Ingress rules allow access to the Jenkins and SSH ports, as well as additional ports for Owasp Zap scans and Sonarqube.

```hcl
resource "aws_security_group" "Jenkins" {
  # ...
}
```

The `aws_network_interface_sg_attachment` resource attaches the security group to the Jenkins network interface.

## Usage

Follow these steps to provision the Jenkins EC2 instance:

1. **Clone the Repository:** Clone this Terraform configuration repository to your local system.

2. **Customize Variables:** Customize the `variables.tf` file to match your specific requirements. You can define variable values in a `.tfvars` file for easy configuration management.

3. **Create AWS Keys:** Create AWS EC2 Keys called ```Falcon.pem``` and add them to the root directory of this project.

4. **Whitelist your IP & add your VPC_id:** Whitelist your IP address in [allowed_cidr](https://github.com/IntelliBridge/Falcon-IaC/blob/917b27ebff35f2dcc13fab56195f16d2121202c5/Jenkins/variables.tf#L36) and add your VPC_ID to [VPC_id](https://github.com/IntelliBridge/Falcon-IaC/blob/917b27ebff35f2dcc13fab56195f16d2121202c5/Jenkins/variables.tf#L42)

5. **Terraform Initialization:** Run the following Terraform commands to initialize the project and download the necessary providers:

   ```shell
   terraform init
   ```

6. **Terraform Apply:** Execute the following command to apply the configuration and create the specified AWS resources:

   ```shell
   terraform apply
   ```

   Terraform will prompt for confirmation before making any changes. Type 'yes' to proceed.

7. **Access Jenkins:** After the EC2 instance is provisioned, access Jenkins by connecting to the public IP address and port 8080. The Jenkins URL and the initial admin password will be displayed in the Terraform output.

## Cleanup

To destroy the AWS resources created by Terraform and clean up your environment, use the following command:

```shell
terraform destroy
```

Please note that this will permanently remove the resources created by this configuration.

## Additional Notes

Here are some additional considerations:

- **AWS Credentials:** Ensure that your AWS credentials are properly configured and accessible to Terraform. Protect sensitive information and credentials as best practice.

- **Sensitive Data:** The initial Jenkins admin password is sensitive and should be treated with care. Ensure it's securely stored and accessed.

- **Customization:** This README provides a basic overview of the Terraform configuration. Depending on your specific requirements and security practices, consider further customization and enhancements.

For more detailed documentation, advanced customization options, and in-depth information, refer to the [Terraform documentation](https://www.terraform.io/docs/index.html) and the official [AWS documentation](https://aws.amazon.com/documentation/).
