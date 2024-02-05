
resource "aws_s3_bucket" "my_bucket" {
  bucket = "your-unique-bucket-name"     # Change this to a unique bucket name
  acl    = "private"
}

resource "aws_s3_bucket" "my_state_bucket" {
  bucket = "your-unique-bucket-name" # Change this to a unique bucket name
  acl    = "private"
  key    = "terraform/state/"

  versioning {
    enabled = true
  }
}


resource "aws_elasticache_cluster" "my_redis_cluster" {
  cluster_id           = "my-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.4"
  port                 = 6379
}


# Creating Lambda IAM resource
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


resource "aws_iam_role_policy_attachment" "lambda_execution_attachment" {
  policy_arn = aws_iam_policy.revoke_keys_role_policy.arn
  role       = aws_iam_role.lambda_iam.name
}


resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_lambda_function.test_lambda.arn
}


resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda_function.arn
    events              = ["s3:ObjectCreated", "s3:ObjectUpdated"]
  }
}
