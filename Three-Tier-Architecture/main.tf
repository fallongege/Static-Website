# Deploy a three tier architecture

# Create a VPC
resource "aws_vpc" "my_Vpc" {
  cidr_block = var.vpccidr

  tags = {
    Name = "ThreeTier-Vpc"
  }
}

#Create 6 subnets in two availability zones
# Create Web Public Subnet-1
resource "aws_subnet" "web-pub-subnt-1" {
  vpc_id                  = aws_vpc.my_Vpc.id
  cidr_block              = var.web-pub-subnt-1Cidr
  availability_zone       = var.Az1
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-PublicSubnet-1"
  }
}
# Create Web Public Subnet-2
resource "aws_subnet" "web-pub-subnt-2" {
  vpc_id                  = aws_vpc.my_Vpc.id
  cidr_block              = var.web-pub-subnt-2Cidr
  availability_zone       = var.Az2
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-PublicSubnet-2"
  }
}
# Create Application Private Subnet-1
resource "aws_subnet" "app-privt-subnt-1" {
  vpc_id                  = aws_vpc.my_Vpc.id
  cidr_block              = var.app-prvt-subnt-1Cidr
  availability_zone       = var.Az1
  map_public_ip_on_launch = false


  tags = {
    Name = "App-PrivtSubnet-1"
  }
}
# Create Application Private Subnet-2
resource "aws_subnet" "app-privt-subnt-2" {
  vpc_id                  = aws_vpc.my_Vpc.id
  cidr_block              = var.app-prvt-subnt-2Cidr
  availability_zone       = var.Az2
  map_public_ip_on_launch = false

  tags = {
    Name = "App-PrivtSubnet-2"
  }
}
# Create Application Private Subnet-1
resource "aws_subnet" "database-privt-subnt-1" {
  vpc_id                  = aws_vpc.my_Vpc.id
  cidr_block              = var.database-prvt-subnt-1Cidr
  availability_zone       = var.Az1
  map_public_ip_on_launch = false

  tags = {
    Name = "Database-PrivtSubnet-1"
  }
}
# Create Application Private Subnet-1
resource "aws_subnet" "database-privt-subnt-2" {
  vpc_id                  = aws_vpc.my_Vpc.id
  cidr_block              = var.database-prvt-subnt-2Cidr
  availability_zone       = var.Az1
  map_public_ip_on_launch = false

  tags = {
    Name = "Database-PrivtSubnet-2"
  }
}
#Create internet Gateway
resource "aws_internet_gateway" "three-tierIgw" {
  vpc_id = aws_vpc.my_Vpc.id

  tags = {
    Name = "Three-Tier-Igw"
  }
}
#Create Elastic IP for Natgateway
resource "aws_eip" "eipforprvtsubnts" {
  vpc = true
  tags = {
    Name = "EIP-For-Three-Tier"
  }
}
#Create Natgateway 
resource "aws_nat_gateway" "three-tier-nat" {
  allocation_id = aws_eip.eipforprvtsubnts.id
  subnet_id     = aws_subnet.web-pub-subnt-1.id
}

#Create Route Table and Route Table Associatio for Web-Subnets
resource "aws_route_table" "web-subnts-rt" {
  vpc_id = aws_vpc.my_Vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.three-tierIgw.id
  }
  tags = {
    Name = "Web-Public-Subnets-Rt"
  }
}
resource "aws_route_table_association" "web-subnt1-asso" {
  subnet_id      = aws_subnet.web-pub-subnt-1.id
  route_table_id = aws_route_table.web-subnts-rt.id
}
resource "aws_route_table_association" "web-subnt2-asso" {
  subnet_id      = aws_subnet.web-pub-subnt-2.id
  route_table_id = aws_route_table.web-subnts-rt.id
}
#Create Route Table and Route Table Associatio for Application-and-Database subnets
resource "aws_route_table" "appdatabase-subnts-rt" {
  vpc_id = aws_vpc.my_Vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.three-tier-nat.id
  }
  tags = {
    Name = "App-Database-Prvt-Subnets-Rt"
  }
}
resource "aws_route_table_association" "app-subnt1-asso" {
  subnet_id      = aws_subnet.app-privt-subnt-1.id
  route_table_id = aws_route_table.appdatabase-subnts-rt.id
}
resource "aws_route_table_association" "app-subnt2-asso" {
  subnet_id      = aws_subnet.app-privt-subnt-2.id
  route_table_id = aws_route_table.appdatabase-subnts-rt.id
}
resource "aws_route_table_association" "database-subnt1-asso" {
  subnet_id      = aws_subnet.database-privt-subnt-1.id
  route_table_id = aws_route_table.appdatabase-subnts-rt.id
}
resource "aws_route_table_association" "database-subnt2-asso" {
  subnet_id      = aws_subnet.database-privt-subnt-2.id
  route_table_id = aws_route_table.appdatabase-subnts-rt.id
}

# Create External Security Group for Application Load balancer allowing HTTP Traffics.

resource "aws_security_group" "application-lb-sg" {
  description = "Allow HTTP inbound traffics"
  vpc_id      = aws_vpc.my_Vpc.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = var.port80
    to_port     = var.port80
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
    Name = "Application Load-Balancer-SG"
  }
}

#Webserver Security Group
resource "aws_security_group" "web-server-sg" {
  description = "Allow HTTP and SSH inbound traffics"
  vpc_id      = aws_vpc.my_Vpc.id

  ingress {
    description = "SSH from Everywhere"
    from_port   = var.port22
    to_port     = var.port22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "HTTP from Load Balancer"
    from_port       = var.port80
    to_port         = var.port80
    protocol        = "tcp"
    security_groups = [aws_security_group.application-lb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebServer-SG"
  }
}

#Applicationserver Security Group allowing SSH traffics from Webserver.
resource "aws_security_group" "application-server-sg" {
  description = "Allow SSH inbound traffics from webserver"
  vpc_id      = aws_vpc.my_Vpc.id

  ingress {
    description     = "SSH from Webserver"
    from_port       = var.port22
    to_port         = var.port22
    protocol        = "tcp"
    security_groups = [aws_security_group.web-server-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ApplicationServer-Security-Group"
  }
}

#Create Database Security Group
resource "aws_security_group" "database-sg" {
  description = "Allow SSH inbound traffic from Appication Server"
  vpc_id      = aws_vpc.my_Vpc.id

  ingress {
    description     = "SSH from Application Server"
    from_port       = var.port3306
    to_port         = var.port3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application-server-sg.id]
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database-SG"
  }
}
# Use data source to fetch ami information.
data "aws_ami" "amazon-linux2" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] #amazon
}
# Provision two instances inside the two public subnets
resource "aws_instance" "webserver1" {
  ami                         = data.aws_ami.amazon-linux2.id
  instance_type               = var.instancetype
  key_name                    = var.Keypair
  subnet_id                   = aws_subnet.web-pub-subnt-1.id
  vpc_security_group_ids      = [aws_security_group.web-server-sg.id]
  associate_public_ip_address = true
  user_data                   = file("install_apache.sh")

  tags = {
    Name = "Web-Server1"
  }
}
resource "aws_instance" "webserver2" {
  ami                         = data.aws_ami.amazon-linux2.id
  instance_type               = var.instancetype
  key_name                    = var.Keypair
  subnet_id                   = aws_subnet.web-pub-subnt-2.id
  vpc_security_group_ids      = [aws_security_group.web-server-sg.id]
  associate_public_ip_address = true
  user_data                   = file("install_apache.sh")

  tags = {
    Name = "Web-Server2"
  }
}
# Provision an instance inside one of the private subnets
resource "aws_instance" "application-server1" {
  ami                         = data.aws_ami.amazon-linux2.id
  instance_type               = var.instancetype
  key_name                    = var.Keypair
  subnet_id                   = aws_subnet.app-privt-subnt-1.id
  vpc_security_group_ids      = [aws_security_group.application-server-sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "Application-Server1"
  }
}
#Create a Load Balancer  to distribute traffics to the webservers
resource "aws_lb" "external-loadbalancer" {
  name               = "Three-Tier-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.application-lb-sg.id]
  subnets            = [aws_subnet.web-pub-subnt-1.id, aws_subnet.web-pub-subnt-2.id]
}
#Create a target Group for the Load Balancer
resource "aws_lb_target_group" "external-loadbalancer-target-GP" {
  name     = "External-LoadBalancer-Target-GP"
  port     = var.port80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_Vpc.id
}
#Create Target Group Attachment  attaching the Traget-group to the Targets(Webservers)
resource "aws_lb_target_group_attachment" "target-gp-attch1" {
  target_group_arn = aws_lb_target_group.external-loadbalancer-target-GP.arn
  target_id        = aws_instance.webserver1.id
  port             = var.port80
  depends_on = [
    aws_instance.webserver1,
  ]
}
resource "aws_lb_target_group_attachment" "target-gp-attch2" {
  target_group_arn = aws_lb_target_group.external-loadbalancer-target-GP.arn
  target_id        = aws_instance.webserver2.id
  port             = var.port80
  depends_on = [
    aws_instance.webserver2,
  ]
}
resource "aws_lb_listener" "enternal-lb-listner" {
  load_balancer_arn = aws_lb.external-loadbalancer.arn
  port              = var.port80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-loadbalancer-target-GP.arn
  }
}
# Create RDS Instance
resource "aws_db_instance" "database-instance" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.23"
  instance_class         = "db.t3.micro"
  name                   = "Three-Tier-MySQL-DataBase"
  username               = "admin"
  password               = var.enter-password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database-sg.id]
}



