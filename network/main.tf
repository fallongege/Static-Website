provider "aws" {
  region    = var.Region
}
  
resource "aws_vpc" "prodVpc" {
  cidr_block = var.vpc_cidr
}
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.prodVpc.id
  count =  "${length(data.aws_availability_zones.azs.names)}"
  cidr_block = "${element(var.subnet_cidr, count.index)}"
  
  
  tags = {
    Name = "Prodsubnet-${count.index+1}"
  }
}


