#variables.
variable "github_repo" {
    description = "Link to glue py script"
    type = string
}

variable "bucket_id" {
    description = "Id of target S3 bucket"
    type = string
}

data "http" "glue_script" {
    url = "https://raw.githubusercontent.com/karmariv/wikimedia-kafka-pipeline/main/wikimedia_aws_glue.py"
}

# Resource to upload the file to S3
  resource "aws_s3_object" "github_file" {
  bucket = "demo-wikimedia-project-karla-rivas"
  key    = "wikimedia_resources/wikimedia_aws_glue.py"
  content_base64 = base64encode(data.http.glue_script.response_body)
}


# Create glue job
resource "aws_glue_job" "wikimedia_glue_job" {
  name              = "wikimedia-glue-job"
  role_arn          = "arn:aws:iam::304691913875:role/wikimedia-glue-role"
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = 60

  command {
    script_location = "s3://demo-wikimedia-project-karla-rivas/wikimedia_resources/wikimedia_aws_glue.py"
  }

  default_arguments = {
    "--job-bookmark-option" = "job-bookmark-disable"
  }
}