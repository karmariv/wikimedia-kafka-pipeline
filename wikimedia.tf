provider "aws" {
    region = "us-west-2"
}

module "s3_bucket" {
    source = "./tf_modules/s3"
    bucket_name = "demo-wikimedia-project-karla-rivas"
}

module "ec2_instance" {
    source = "./tf_modules/ec2"
    bucket_id = module.s3_bucket.bucket_id
}

module "glue_crawler" {
    source = "./tf_modules/glue_crawler"
    bucket_id = module.s3_bucket.bucket_id
}

module "glue_etl" {
    source = "./tf_modules/glue_etl"
    bucket_id = "demo-wikimedia-project-karla-rivas"
    github_repo = "https://github.com/karmariv/wikimedia-kafka-pipeline.git/raw/main/wikimedia_aws_glue.py"
}

# Show IP assigned to EC2 Instance
output "module_output" {
    value = module.ec2_instance.EIP
}




