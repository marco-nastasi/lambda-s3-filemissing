provider "aws" {
  region = "eu-central-1"
}

resource "random_id" "random_bucket" {
  byte_length = 10
}

resource "aws_s3_bucket" "backups_bucket" {
  bucket = "${random_id.random_bucket.hex}-s3-test-bucket"
  tags   = local.tags
}

resource "aws_s3_bucket_ownership_controls" "backups_bucket_ownership_controls" {
  bucket = aws_s3_bucket.backups_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "backups_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.backups_bucket_ownership_controls]

  bucket = aws_s3_bucket.backups_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "backups_bucket_versioning" {
  bucket = aws_s3_bucket.backups_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "objects_customer1" {
  #Must have versioning enabled first
  depends_on = [aws_s3_bucket_versioning.backups_bucket_versioning]

  count  = length(var.dates)
  key    = "CUSTOMER1${var.dates[count.index]}terraform.tf"
  bucket = aws_s3_bucket.backups_bucket.id
  source = "terraform.tf"
  tags   = local.tags
}

resource "aws_s3_object" "objects_customer2" {
  #Must have versioning enabled first
  depends_on = [aws_s3_bucket_versioning.backups_bucket_versioning]

  count  = length(var.dates)
  key    = "CUSTOMER2${var.dates[count.index]}terraform.tf"
  bucket = aws_s3_bucket.backups_bucket.id
  source = "terraform.tf"
  tags   = local.tags
}

resource "aws_s3_object" "objects_customer3" {
  #Must have versioning enabled first
  depends_on = [aws_s3_bucket_versioning.backups_bucket_versioning]

  count  = length(var.dates)
  key    = "CUSTOMER3${var.dates[count.index]}terraform.tf"
  bucket = aws_s3_bucket.backups_bucket.id
  source = "terraform.tf"
  tags   = local.tags
}

resource "aws_s3_object" "objects_customer4" {
  #Must have versioning enabled first
  depends_on = [aws_s3_bucket_versioning.backups_bucket_versioning]

  count  = length(var.dates)
  key    = "CUSTOMER4${var.dates[count.index]}terraform.tf"
  bucket = aws_s3_bucket.backups_bucket.id
  source = "terraform.tf"
  tags   = local.tags
}

resource "aws_s3_object" "objects_customer5" {
  #Must have versioning enabled first
  depends_on = [aws_s3_bucket_versioning.backups_bucket_versioning]

  count  = length(var.dates)
  key    = "CUSTOMER5${var.dates[count.index]}terraform.tf"
  bucket = aws_s3_bucket.backups_bucket.id
  source = "terraform.tf"
  tags   = local.tags
}

resource "aws_sns_topic" "lambda_topic" {
  name       = "Sample-lambda-topic"
  fifo_topic = false

  tags = local.tags
}

resource "aws_sns_topic_subscription" "lambda_topic_subscription" {
  depends_on = [aws_sns_topic.lambda_topic]
  count      = length(var.subscribers)
  topic_arn  = aws_sns_topic.lambda_topic.arn
  protocol   = "email"
  endpoint   = var.subscribers[count.index]
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "sts:AssumeRole"
          ],
          "Principal" : {
            "Service" : [
              "lambda.amazonaws.com"
            ]
          }
        }
      ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda-s3-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:Get*",
            "s3:List*",
            "s3:Describe*",
            "s3-object-lambda:Get*",
            "s3-object-lambda:List*"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "lambda_sns_policy" {
  name = "lambda-sns-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "sns:Publish"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "lambda_cloudwatch_policy" {
  name = "lambda-cloudwatch-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

data "archive_file" "lambda-file" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function.zip"
  function_name = "lambda-file-not-present-s3"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda-file.output_base64sha256

  runtime = "python3.11"

  environment {
    variables = {
      foo = "bar"
    }
  }

  tags = local.tags
}

resource "aws_cloudwatch_event_rule" "cronjob_lambda_5min" {
  name                = "CronjobLambdaMissingFileinS3Every5Min"
  description         = "Schedule execution of Lambda Function, every 5 minutes"
  schedule_expression = "rate(5 minutes)"
  tags                = local.tags
}

resource "aws_cloudwatch_event_rule" "cronjob_lambda_19hrs" {
  name                = "CronjobLambdaMissingFileinS3At19Hrs"
  description         = "Schedule execution of Lambda Function, every day at 19:00"
  schedule_expression = "cron(0 19 * * ? *)"
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "trigger_lambda_5min" {
  arn       = aws_lambda_function.test_lambda.arn
  rule      = aws_cloudwatch_event_rule.cronjob_lambda_5min.name
  target_id = "lambda"
}

resource "aws_cloudwatch_event_target" "trigger_lambda_19hrs" {
  arn       = aws_lambda_function.test_lambda.arn
  rule      = aws_cloudwatch_event_rule.cronjob_lambda_19hrs.name
  target_id = "lambda"
}

resource "aws_lambda_permission" "allow_eventbridge_lambda_5min" {
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  action        = "lambda:InvokeFunction"
  statement_id  = "AllowExecutionFromEventbridgeEvery5Min"
  source_arn    = aws_cloudwatch_event_rule.cronjob_lambda_5min.arn
}

resource "aws_lambda_permission" "allow_eventbridge_lambda_19hrs" {
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  action        = "lambda:InvokeFunction"
  statement_id  = "AllowExecutionFromEventbridgeAt19Hrs"
  source_arn    = aws_cloudwatch_event_rule.cronjob_lambda_19hrs.arn
}

locals {
  tags = {
    terraform = "true"
    env       = "test"
  }
}
