# demicon-poc

# directory structure.

 * [archieve]()  has a code to zip the lambda_function.py file which will be used by lambda function resource to create lambda function
 * [task]() has a actual code to create lambda function resources
 * [README.md]()
 * [lambda_function.py]() lambda function to read terraform state file values from s3 bucket

**Prerequisite**
1)terraform,git should be installed and should have access and secret key inorder to run terraform code.
2) configure aws creditials inside .aws/credentials file.
3) create a s3 bucket and update terraform state file inside it. update task/terraform.tfvars file with bucket_name and file_name variables.

**how to run the code**
1) clone the repo.
2) navigate to archive directory - run terraform init - terraform plan to validate changes and last terraform Apply (it will create a zip file at root of the repo)
3) navigate to task directory  and update the terraform.tfvars file with all correct details.
4) run terraform init - terraform plan to validate the changes
5) run terraform apply -var "resource_name=resource_name" where resource_name is the name of the resource which values you want fetch from terraform state file.


**above procedure will create lambda function with all required permission. go to aws console-> open lambda function -> create and trigger test events -> it will return you resource value which was present inside terraform state file output section**

**Tips for best practice -> you can use remote backend if you are working in a team*
