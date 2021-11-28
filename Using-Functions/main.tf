provider "aws" {
  region = "us-east-1"

}
resource "aws_vpc" "web_vpc" {
  cidr_block           = var.vpccidr
  enable_dns_hostnames = true

  tags = {
    Name = "Web VPC"
  }

}
resource "aws_subnet" "ac_privateweb_subnet" {
  # Use the count meta-argument to create multiple copies
  count  = 4
  vpc_id = aws_vpc.web_vpc.id
  # cidrsubnet function splits a cidr block into subnets
  cidr_block = cidrsubnet(var.vpccidr, 8, count.index)
  # element retrieves a list element at a given index
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "ACPrivateWebSubnet ${count.index + 1}"
  }
}
resource "aws_subnet" "ac_public_subnet" {
  vpc_id = aws_vpc.web_vpc.id
  # Use the count meta-argument to create multiple copies
  count = 2
  # cidrsubnet function splits a cidr block into subnets while the index loops through
  cidr_block = cidrsubnet(var.vpccidr, 8, count.index + 4)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "ACPublicSubnet ${count.index + 1}"
  }
}
resource "aws_internet_gateway" "acigw" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "AcIGW"
  }
}
resource "aws_route_table" "acroutetable" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.acigw.id
  }

  tags = {
    Name = "ACRouteTable"
  }
}
resource "aws_route_table_association" "acrouttableass" {
  subnet_id      = aws_subnet.ac_public_subnet[0].id
  route_table_id = aws_route_table.acroutetable.id
}
resource "aws_route_table_association" "acrouttableass1" {
  subnet_id      = aws_subnet.ac_public_subnet[1].id
  route_table_id = aws_route_table.acroutetable.id
}
resource "aws_security_group" "elb_sg" {
  name        = "ELB Security Group"
  description = "Allow incoming HTTP traffic from the internet"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "Web Server Security Group"
  description = "Allow HTTP traffic from ELB security group"
  vpc_id      = aws_vpc.web_vpc.id

  # HTTP access from the VPC
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_sg.id}"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webinstance" {
  ami                         = lookup(var.ami_ids, "us-east-1")
  count                       = 2
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.web_sg.id]
  subnet_id                   = aws_subnet.ac_public_subnet.*.id[count.index]
  user_data = "${file("userdata.sh")}"
  tags = {
    Name = "Webserver ${count.index + 1}"
  }
}
# Create a new load balancer
resource "aws_elb" "acelb" {
  name               = "Web-Ac-ELB"
  instances = "${aws_instance.webinstance.*.id}"
  subnets = "${aws_subnet.ac_public_subnet.*.id}"
  security_groups = ["${aws_security_group.elb_sg.id}"]
  
  # Listen for HTTP requests and distribute them to the instances
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
# Check instance health every 10 seconds
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  tags = {
    Name = "ACWeb-ELB"
  }
}