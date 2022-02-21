# /////////VARIABLES/////////
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "aws_region" {}
variable "aws_vpc_cidr" {}
variable "aws_subnet_cidr" {}
# /////////VARIABLES/////////



# /////////PROVIDER/////////

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region = var.aws_region

}
# /////////PROVIDER/////////

# /////////Resources/////////
# vpc resource 
resource "aws_vpc" "project2_vpc" {
  cidr_block = var.aws_vpc_cidr 
    
  tags = {
    Name = "project2"
  }  
}  


# subnet resource 
resource "aws_subnet" "project2_subnet" {
  vpc_id = aws_vpc.project2_vpc.id
  cidr_block = var.aws_subnet_cidr 
  availability_zone = "us-east-2a" 
  tags = {
    Name = "project2"
  }  
}

# internet gateway
resource "aws_internet_gateway" "project2_igw" {
  vpc_id = aws_vpc.project2_vpc.id

  tags = {
    Name = "project2"
  }
}

# route table
resource "aws_route_table" "project2_route" {
  vpc_id = aws_vpc.project2_vpc.id

  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.project2_igw.id
  }
  tags = {
    Name = "project2"
  }
}

# aws route table association
resource "aws_route_table_association" "project2_route_tbl_association" {
  subnet_id = aws_subnet.project2_subnet.id
  route_table_id = aws_route_table.project2_route.id
}

# aws security group
resource "aws_security_group" "project2_sg" {
  name = "Project2_SG"
  vpc_id = aws_vpc.project2_vpc.id
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project2"
  }
}

# aws instance
resource "aws_instance" "project2_ec2" {
  ami = "ami-0b614a5d911900a9b"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.project2_subnet.id
  security_groups = [aws_security_group.project2_sg.id]
  associate_public_ip_address = true
  key_name = "project2" 
  tags = {
    Name = "project2"
  }
}
# /////////Resources/////////


# /////////Data/////////
#date "aws_ami" "amazon-linux2" {
#  most_recent = true

#  filter {
#    name = "name"
#    values = 
#  }
#}

data "aws_instance" "ec2_instance_created" {
  filter {
    name = "tag:Name"
    values = ["project2"]
  }
  depends_on = [
    aws_instance.project2_ec2
  ]
}
# /////////Data/////////

# /////////Output/////////
output "fetched_from_aws" {
  value = data.aws_instance.ec2_instance_created.public_ip
}
# /////////Output/////////



