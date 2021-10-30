resource "aws_vpc" "TestVPC" {
  cidr_block           = var.vpccidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "Test-VPC"
  }
}
# Internet Gateway a
resource "aws_internet_gateway" "TestIGW" {
  vpc_id = aws_vpc.TestVPC.id

  tags = {
    Name = "Test-IGW"
  }
}
# Public Subnet1
resource "aws_subnet" "TestPubSubnet1" {
  vpc_id                  = aws_vpc.TestVPC.id
  cidr_block              = var.pubsubnet1_cidr
  availability_zone       = var.Az1
  map_public_ip_on_launch = true
 

  tags = {
    Name = "Test_PublicSubnet1"
  }
}

#Public subnet2
resource "aws_subnet" "TestPubSubnet2" {
  vpc_id                  = aws_vpc.TestVPC.id
  cidr_block              = var.pubsubnet2_cidr
  availability_zone       = var.Az2
  map_public_ip_on_launch = true


  tags = {
    Name = "Test_PublicSubnet2"
  }
}

#Private Subnet1
resource "aws_subnet" "TestPrvtSubnet1" {
  vpc_id            = aws_vpc.TestVPC.id
  cidr_block        = var.prvtsubnet1_cidr
  availability_zone = var.Az1
  tags = {
    Name = "TestPrivate_Subnet1"
  }
}

#Private Subnet2
resource "aws_subnet" "TestPrvtSubnet2" {
  vpc_id            = aws_vpc.TestVPC.id
  cidr_block        = var.prvtsubnet2_cidr
  availability_zone = var.Az2

  tags = {
    Name = "TestPrivate_Subnet2"
  }
}

#Elatic Ip
resource "aws_eip" "eip-for-natgateway" {
  vpc = true

  tags = {
    Name = "EIP-1"
  }
}

# NATGateway
resource "aws_nat_gateway" "NATGateway" {
  allocation_id = aws_eip.eip-for-natgateway.id
  subnet_id     = aws_subnet.TestPubSubnet1.id
  depends_on    = [aws_internet_gateway.TestIGW]

  tags = {
    Name = "Test-NATGateway"
  }

}
# Public Route Table
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.TestVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TestIGW.id
  }
  tags = {
    Name = "Public_Subnet_RT"
  }
}

# Public Route Table Association1; TestPubSubnet1
resource "aws_route_table_association" "PublicSubnt1_Asso" {
  subnet_id      = aws_subnet.TestPubSubnet1.id
  route_table_id = aws_route_table.PublicRT.id
}

# Public Route Table Association2; TestPubSubnet2
resource "aws_route_table_association" "PublicSubnt2_Asso" {
  subnet_id      = aws_subnet.TestPubSubnet2.id
  route_table_id = aws_route_table.PublicRT.id
}

#Private Subnet Route table
resource "aws_route_table" "PrvtRT" {
  vpc_id = aws_vpc.TestVPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATGateway.id
  }

  tags = {
    Name = "Private-RouteTable"
  }
}
# Private Subnet Association1; TestPrvtSubnet1
resource "aws_route_table_association" "PrvtSubnt1_Asso" {
  subnet_id      = aws_subnet.TestPrvtSubnet1.id
  route_table_id = aws_route_table.PrvtRT.id
}
# Private Subnet Association2; TestPrvtSubnet2
resource "aws_route_table_association" "PrvtSubnt2_Asso" {
  subnet_id      = aws_subnet.TestPrvtSubnet2.id
  route_table_id = aws_route_table.PrvtRT.id
}
#External Security Group
resource "aws_security_group" "external_security_group" {
  name        = "external_security_group"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.TestVPC.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH  traffic"
    from_port   = 22
    to_port     = 22
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
    Name = "External_Security_Group"
  }
}

#Internal Security Group
resource "aws_security_group" "internal_security_group" {
  name        = "internal_security_group"
  description = "Allow all inbound traffic from external_security_group"
  vpc_id      = aws_vpc.TestVPC.id

  ingress {
    description     = "Allow all traffic from external_sg"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.external_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Internal_Security_Group"
  }
}

# Create a Network interface 
resource "aws_network_interface" "TestInterface" {
  subnet_id = aws_subnet.TestPubSubnet1.id

  tags = {
    Name = "primary_network_interface"
  }
}
# Specify data source for an ec2 instsnce to be provisioned!!
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] #Amazon
}

# Provision an ec2 instance
resource "aws_instance" "TestInstance1" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  key_name                    = var.Testkey_name


  network_interface {
    network_interface_id = aws_network_interface.TestInterface.id
    device_index         = 0
  }

  tags = {
    Name = "TestInstance"
  }

}
