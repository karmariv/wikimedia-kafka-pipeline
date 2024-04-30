#variables
variable "bucket_id" {
    description = "Id of target S3 bucket"
    type = string
}

# Create AWS Glue resources
resource "aws_glue_catalog_database" "wikimedia_db" {
  name = "wikimedia_db"
}


resource "aws_glue_crawler" "wikimedia_changes" {
  database_name = aws_glue_catalog_database.wikimedia_db.name
  name          = "wikimedia_changes_tf"
  role          = aws_iam_role.wikimedia_glue_role.arn

  s3_target {
    path = "s3://${var.bucket_id}/wikimedia_changes"
  }
}

resource "aws_glue_crawler" "wikimedia_changes_aggr" {
  database_name = aws_glue_catalog_database.wikimedia_db.name
  name          = "wikimedia_changes_aggr_tf"
  role          = aws_iam_role.wikimedia_glue_role.arn

  s3_target {
    path = "s3://${var.bucket_id}/wikimedia_changes_aggr"
  }
}


# Create an IAM role for AWS Glue
resource "aws_iam_role" "wikimedia_glue_role" {
  name = "wikimedia-glue-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach an IAM policy to the Glue role for S3 access
resource "aws_iam_role_policy" "wikimedia_glue_policy" {
  name = "wikimedia-glue-policy"
  role = aws_iam_role.wikimedia_glue_role.id

  policy = <<EOF
{
 	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:ListBucket",
				"s3:GetBucketLocation",
				"s3:ListAllMyBuckets"
			],
			"Effect": "Allow",
			"Resource": [
				"arn:aws:s3:::demo-wikimedia-project-karla-rivas",
				"arn:aws:s3:::demo-wikimedia-project-karla-rivas/*"
			]
		},
		{
			"Action": [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Effect": "Allow",
			"Resource": [
				"arn:aws:logs:*:*:*:/aws-glue/*"
			]
		},
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"glue:*"
			],
			"Resource": [
				"*"
			]
		}
	]
}
EOF
}