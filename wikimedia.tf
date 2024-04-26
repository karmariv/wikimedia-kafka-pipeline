provider "aws" {
    region = "us-west-2"
}

# Create an EC2 instance
resource "aws_instance" "kafka_instance" {
    ami           = "ami-0395649fbe870727e"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.kafka_instance_sg_web.name]


    # Install Kafka, Java, and Python
    user_data = <<-EOF
    #!/bin/bash
    sudo cd ~
    sudo yum update -y
    sudo amazon-linux-extras install java-1.8.0-openjdk -y
    #sudo yum install kafka -y
    sudo wget https://downloads.apache.org/kafka/3.7.0/kafka_2.12-3.7.0.tgz
    sudo tar -xvf kafka_2.12-3.7.0.tgz
    sudo yum install python3 -y
    sudo pip3 install json boto3 datetime ConfigParser kafka-python sseclient pandas pyarrow
    sudo yum update -y
    sudo yum install git -y
    EOF

    # Attach an IAM role for S3 access
    # iam_instance_profile = aws_iam_instance_profile.kafka_instance_profile.name

    tags = {
        Name = "Kafka Instance"
    }
}

resource "aws_eip" "elasticeip" {
    instance = aws_instance.kafka_instance.id
}

output "EIP" {
    value = aws_eip.elasticeip.public_ip
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
