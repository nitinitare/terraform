rovider "aws" {
  region = "us-east-1"
  access_key = "AKIAISRLBZFYYBL3KTCQ"
  secret_key = "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"
}
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}
# Create an internet gateway to give our subnet access to the open internet
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}
# Give the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet-gateway.id}"
}
# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags {
    Name = "Public"
   }
}

# Our default security group to access
# instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "terraform_securitygroup"
  description = "Used for public instances"
  vpc_id      = "${aws_vpc.vpc.id}"
# SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
  }

resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami = "ami-0ac019f4fcb7cb7e6"
  key_name = "terraform"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  # We're going to launch into the public subnet for this.
  # Normally, in production environments, webservers would be in
  # private subnets.
  subnet_id = "${aws_subnet.default.id}"
  provisioner "remote-exec"{
    inline = [
     "sudo apt-get -y update"
      ]
  connection {
    type = "ssh"
    user ="ubuntu"
    private_key = "${file("terraform.pem")}" ### provide the key
    timeout = "4m"
    agent = false
   }
  }
}

  
