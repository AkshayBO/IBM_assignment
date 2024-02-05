# IBM-ASSIGNMENT

# directory structure.

 * [archieve]()  has a code to zip the lambda_function.py file which will be used by lambda function resource to create lambda function
 * [task]() has a actual code to create lambda function,s3 and ElastiCache resources
 * [README.md]()
 * [lambda_function.py]() lambda function to get updated/created filename and timestamp from s3 bucket

**Prerequisite**
1)terraform,git should be installed and should have access and secret key inorder to run terraform code.
2) configure aws creditials inside .aws/credentials file.
3) create a s3 bucket and update terraform state file inside it. update task/terraform.tfvars file with bucket_name and file_name variables.

**how to run the code**
1) clone the repo.
2) navigate to archive directory - run terraform init - terraform plan to validate changes and last terraform Apply (it will create a zip file at root of the repo)
3) navigate to task directory  and update the terraform.tfvars file with all correct details.
4) run terraform init  
5) terraform plan - to validate the changes
6) run terraform apply - to apply changes
