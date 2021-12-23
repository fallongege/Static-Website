resource "aws_vpc" "Testvpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "${var.tenancy}"

  tags = {
    Name = "Testvpc"
  }
}
resource "aws_subnet" "Testsubnet" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${var.subnet_cidr}"

  tags = {
    Name = "TestSubnet"
  }
}

resource "aws_internet_gateway" "TestIGW" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "TEST-IGW"
  }
}
resource "aws_route_table" "TestRouteTable" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TestIGW.id
  }

  tags = {
    Name = "TestRT"
  }
}
resource "aws_route_table_association" "TestRouteTable_Asso" {
  subnet_id      = "${var.subnet_id}"
  route_table_id = "${var.route_table_id}"
}

# Outputs
 output "vpc_id" {
     value = "${aws_vpc.Testvpc.id}"
   
 }
 output "gateway_id" {
     value = "${aws_internet_gateway.TestIGW.id}"
 }
 
 output "subnet_id" {
     value = "${aws_subnet.Testsubnet.id}"
   }

 
 output "route_table_id" {
     value = "${aws_route_table.TestRouteTable.id}"
}
output "route_table_association_id" {
    value = "${aws_route_table_association.TestRouteTable_Asso.id}"
  
}