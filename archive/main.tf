# create a archive file a lambda function

data "archive_file" "lambda_my_function" {
  type             = "zip"
  source_file      = "../lambda_function.py"
  output_file_mode = "0666"
  output_path      = "../lambda_function.zip"
}
