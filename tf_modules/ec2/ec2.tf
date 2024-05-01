#variables
variable "bucket_id" {
    description = "Id of target S3 bucket"
    type = string
}

# Create an EC2 instance
resource "aws_instance" "kafka_instance" {
    ami           = "ami-0395649fbe870727e"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.kafka_instance_sg_web.name]


    # Install Kafka, Java, and Python
    user_data = <<-EOF
    #!/bin/bash
    # Install packages
    sudo yum update -y
    sudo yum install java -y
    sudo yum install python3 -y
    sudo yum install python3-pip -y
    sudo pip3 install boto3 datetime ConfigParser kafka-python sseclient pandas pyarrow
    sudo yum install git -y
    # Create folders 
    sudo mkdir /home/ec2-user/kafka
    sudo mkdir /home/ec2-user/wikimedia_src
    sudo wget -P /home/ec2-user/kafka https://downloads.apache.org/kafka/3.7.0/kafka_2.12-3.7.0.tgz
    sudo tar -xzvf /home/ec2-user/kafka/kafka_2.12-3.7.0.tgz -C /home/ec2-user/kafka
    sudo git clone https://github.com/karmariv/wikimedia-kafka-pipeline.git /home/ec2-user/wikimedia_src
    EOF

    # Attach an IAM role for S3 access
    iam_instance_profile = aws_iam_instance_profile.kafka_instance_profile.name

    tags = {
        Name = "Kafka Instance"
    }
}


# Create a security group for the EC2 instance
resource "aws_security_group" "kafka_instance_sg_web" {
  name = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere
  }

  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "elasticeip" {
    instance = aws_instance.kafka_instance.id
}


# Create an IAM role for the EC2 instance.git 
resource "aws_iam_role" "kafka_instance_role" {
  name = "kafka-instance-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

# Attach an IAM policy to the role for S3 access
resource "aws_iam_role_policy" "kafka_instance_policy" {
  name = "kafka-instance-policy"
  role = aws_iam_role.kafka_instance_role.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource": [
          "arn:aws:s3:::${var.bucket_id}",
          "arn:aws:s3:::${var.bucket_id}/*"
        ]
      }
    ]
  }
  EOF
}

# Create an IAM instance profile
resource "aws_iam_instance_profile" "kafka_instance_profile" {
  name = "kafka-instance-profile"
  role = aws_iam_role.kafka_instance_role.name
}

output "EIP" {
    value = aws_eip.elasticeip.public_ip
}
