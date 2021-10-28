#Create VPC
resource "aws_vpc" "DevVpc" {
  cidr_block = var.vpc_cidr

  instance_tenancy = "default"

  tags = {
    Name = "Dev-vpc"
  }
}

#Create Subnets
resource "aws_subnet" "DevSubnet1" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = var.subnet1_cidr
  availability_zone = var.az1

  tags = {
    Name = "Dev-Subnet1"
  }
}

resource "aws_subnet" "DevSubnet2" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = var.subnet2_cidr
  availability_zone = var.az2

  tags = {
    Name = "Dev-Subnet2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "DevIgw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "Dev_IGW"
  }
}
#Create Route table
resource "aws_route_table" "dev-RouteTable" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.gateway_id}"
  }

  tags = {
    Name = "Dev_RouteTable"
  }
}

#Create Route Table Associations for the Subnets
resource "aws_route_table_association" "DevSubnt1_Asso" {
  subnet_id      = "${var.subnet1_id}"
  route_table_id = aws_route_table.dev-RouteTable.id
}
resource "aws_route_table_association" "DevSubnt2_Asso" {
  subnet_id      ="${var.subnet2_id}"
  route_table_id = aws_route_table.dev-RouteTable.id
}
#Create Security Groups
resource "aws_security_group" "Dev-SG" {
  name        = "dev-SG"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = "${var.vpc_id}"


  ingress {
    description = "HTTPS from VPC"
    from_port   = var.serverport1
    to_port     = var.serverport1
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "HTTP from VPC"
    from_port   = var.serverport2
    to_port     = var.serverport2
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dev-Security-Group"
  }
}
#Outputs
output "vpc_id" {
     value = "${aws_vpc.DevVpc.id}"
}
output "gateway_id" {
     value = "${aws_internet_gateway.DevIgw.id}"
 }
 output "subnet1_id" {
     value = "${aws_subnet.DevSubnet1.id}"
   
 }
  output "subnet2_id" {
     value = "${aws_subnet.DevSubnet2.id}"
   
 }

 output "Routetable_id" {
     value = "${aws_route_table.dev-RouteTable.id}"
   
 }

 