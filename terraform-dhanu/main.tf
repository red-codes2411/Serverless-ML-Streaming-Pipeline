terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Mumbai Region
}

# 1. Kinesis Data Stream
resource "aws_kinesis_stream" "feature_stream" {
  name             = "ml-feature-stream-dhanu"
  shard_count      = 1
  retention_period = 24

  tags = {
    Environment = "Dev"
    Owner       = "Dhanu"
  }
}

# 2. IAM Role for SageMaker Feature Store
resource "aws_iam_role" "sagemaker_role_dhanu" {
  name = "sagemaker-feature-store-role-dhanu"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonSageMakerFullAccess to the role
resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_role_dhanu.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# 3. SageMaker Feature Group (Online Store Only)
resource "aws_sagemaker_feature_group" "transactions_feature_group" {
  feature_group_name             = "transactions-feature-group-dhanu"
  record_identifier_feature_name = "user_id"
  event_time_feature_name        = "timestamp"
  role_arn                       = aws_iam_role.sagemaker_role_dhanu.arn

  # Define the schema matching our Streamlit incoming data fields
  feature_definition {
    feature_name = "user_id"
    feature_type = "String"
  }

  feature_definition {
    feature_name = "timestamp"
    feature_type = "String"
  }

  feature_definition {
    feature_name = "amount"
    feature_type = "Fractional" # Represents floating point transactions
  }

  feature_definition {
    feature_name = "location_risk"
    feature_type = "String"
  }

  # Ensure the Online Store is enabled for real-time low-latency serving
  online_store_config {
    enable_online_store = true
  }

  tags = {
    Environment = "Dev"
    Owner       = "Dhanu"
  }
}
# --- NEW CODE TO APPEND TO main.tf ---

# 4. IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role_dhanu" {
  name = "lambda-kinesis-sagemaker-role-dhanu"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Give Lambda permission to read from Kinesis and write basic logs
resource "aws_iam_role_policy_attachment" "lambda_kinesis_access" {
  role       = aws_iam_role.lambda_exec_role_dhanu.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

# Give Lambda permission to write to the SageMaker Feature Store
resource "aws_iam_role_policy" "lambda_sagemaker_policy_dhanu" {
  name = "LambdaSageMakerPutRecordPolicy"
  role = aws_iam_role.lambda_exec_role_dhanu.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sagemaker:PutRecord"
      Resource = aws_sagemaker_feature_group.transactions_feature_group.arn
    }]
  })
}

# 5. Package the Python code into a ZIP file automatically
data "archive_file" "lambda_zip_dhanu" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_dhanu.zip"
}

# 6. Create the Lambda Function
resource "aws_lambda_function" "stream_processor_dhanu" {
  filename         = data.archive_file.lambda_zip_dhanu.output_path
  function_name    = "kinesis-to-sagemaker-processor-dhanu"
  role             = aws_iam_role.lambda_exec_role_dhanu.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip_dhanu.output_base64sha256
}

# 7. Map Kinesis to Lambda (The Trigger)
resource "aws_lambda_event_source_mapping" "kinesis_trigger_dhanu" {
  event_source_arn  = aws_kinesis_stream.feature_stream.arn
  function_name     = aws_lambda_function.stream_processor_dhanu.arn
  starting_position = "LATEST"
}