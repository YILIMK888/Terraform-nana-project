provider "aws" {
    region = "ap-southeast-2"
    
}

variable vpc_cidr_blocks {}
variable subnet_cidr_blocks {}
variable avail_zone {}
variable env_prefix {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}


resource "aws_vpc" "nana-demo-project-vpc" {
    cidr_block = var.vpc_cidr_blocks
    tags = {
      Name: "${var.env_prefix}-vpc"
      
    }
}




resource "aws_subnet" "nana-demo-project-subnet-1" {
    vpc_id = aws_vpc.nana-demo-project-vpc.id
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.avail_zone 
    tags = {
      Name: "${var.env_prefix}-subnet-1"      
    }
    
}


resource "aws_internet_gateway" "mynanaproject-igw" {
    vpc_id = aws_vpc.nana-demo-project-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
  
}

 resource "aws_route_table" "mynanaproject-route-table" {
    vpc_id = aws_vpc.nana-demo-project-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.mynanaproject-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
   
 }

 resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.nana-demo-project-subnet-1.id
    route_table_id = aws_route_table.mynanaproject-route-table.id
 }

 resource "aws_security_group" "nanaproject-sg" {
   name = "nanaproject-sg"
   vpc_id = aws_vpc.nana-demo-project-vpc.id
   
   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
   }

   ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = [  ]
   }

   tags = {
        Name: "${var.env_prefix}-sg"
    }
 }



 data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
      name = "name"
      values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
    }
    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
   
 }

 output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
   
 }


  output "ec2_public_ip" {
    value = aws_instance.nanaproject-server.public_ip
   
 }

 resource "aws_key_pair" "nana-ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)

   
 }

resource "aws_instance" "nanaproject-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    
    subnet_id = aws_subnet.nana-demo-project-subnet-1.id
    vpc_security_group_ids = [ aws_security_group.nanaproject-sg.id ]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.nana-ssh-key.key_name

    tags = {
        Name = "${var.env_prefix}-server"
    }
   
 }