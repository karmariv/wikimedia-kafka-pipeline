#variables
variable "bucket_name" {
    description = "Name of S3 bucket"
    type = string
}


# Create the S3 bucket
resource "aws_s3_bucket" "wikimedia_bucket" {
  bucket = var.bucket_name
}

# Create the first subfolder where all data comming from wikimedia api will be stored
resource "aws_s3_object" "wikimedia_changes" {
  bucket = aws_s3_bucket.wikimedia_bucket.id
  key    = "wikimedia_recent_changes/" # The trailing slash is important to create a subfolder
}

# Create the second subfolder, output from glue job will be stored here
resource "aws_s3_object" "wikimedia_groupings" {
  bucket = aws_s3_bucket.wikimedia_bucket.id
  key    = "wikimedia_changes_aggr/" # The trailing slash is important to create a subfolder
}

# Create a subfolder where all the glue scripts will be stored
resource "aws_s3_object" "wikimedia_resources" {
  bucket = aws_s3_bucket.wikimedia_bucket.id
  key    = "wikimedia_resources/" # The trailing slash is important to create a subfolder
}

output "bucket_id" {
    value = aws_s3_bucket.wikimedia_bucket.id
}
