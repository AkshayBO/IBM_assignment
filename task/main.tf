
# created bucket to apply lambda trigger on it
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name     # Change this to a unique bucket name
  acl    = "private"
}

# created bucket to store state file
resource "aws_s3_bucket" "my_state_bucket" {
  bucket = var.state_bucket_name # Change this to a unique bucket name
  acl    = "private"
  key    = "terraform/state/"

  versioning {
    enabled = true
  }
}

#This will create elasticache(redis) single node cluster
resource "aws_elasticache_cluster" "my_redis_cluster" {
  cluster_id           = "my-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.4"
  port                 = 6379
}


# Creating Lambda IAM resource(role)
resource "aws_iam_role" "lambda_iam" {
  name = var.lambda_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Creating Lambda IAM resource(policies)
resource "aws_iam_role_policy" "revoke_keys_role_policy" {
  name = var.lambda_iam_policy_name
  role = aws_iam_role.lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:Put*",
        "elasticache:Put*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.my_bucket.arn}/*",
        "${aws_elasticache_cluster.my_redis_cluster.arn}/*"
      ]
    }
  ]
}
EOF
}


# This will create lambda function
resource "aws_lambda_function" "test_lambda" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_iam.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = var.runtime
  timeout          = var.timeout
  filename         = "../lambda_function.zip"
  
  source_code_hash = filebase64sha256("../lambda_function.zip")
  environment {
    variables = {
      REDIS_ENDPOINT = aws_elasticache_cluster.my_redis_cluster.cache_nodes.0.address
    }
  }
}

# attching policy to created role
resource "aws_iam_role_policy_attachment" "lambda_execution_attachment" {
  policy_arn = aws_iam_policy.revoke_keys_role_policy.arn
  role       = aws_iam_role.lambda_iam.name
}

#  grant permission for an AWS Lambda function to be invoked by an S3 event
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_lambda_function.test_lambda.arn
}

# invoking an AWS Lambda function in response to events occurring within the S3 bucket.
resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda.arn
    events              = ["s3:ObjectCreated", "s3:ObjectUpdated"]
  }
}
