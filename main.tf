provider "aws" {
    region = "ap-southeast-2"
    
}


variable "environment" {
    description = "deployment environment"  
  
}
resource "aws_vpc" "nana-course-vpc" {
    cidr_block = var.cidr_blocks[0]  
    tags = {
      Name: var.environment
      
    }
}

variable "cidr_blocks" {
    description = "cidr blocks" 
    type = list(string)
}


resource "aws_subnet" "nana-dev-subnet-1" {
    vpc_id = aws_vpc.nana-course-vpc.id
    cidr_block = var.cidr_blocks[1]
    availability_zone = "ap-southeast-2a" 
    tags = {
      Name: "Nanatf-subnet-1-dev"
      
    }
}

data "aws_vpc" "existing_vpc" {
  default = true
}

resource "aws_subnet" "nana-dev-subnet-2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = var.cidr_blocks[2]
    availability_zone = "ap-southeast-2a" 
     tags = {
      Name: "Nanatf-subnet-2-default"
    }
}

output "nana-vpc-id" {
    value = aws_vpc.nana-course-vpc.id 
}

output "nana-subnet-id" {
    value = aws_subnet.nana-dev-subnet-1.id 
}