variable "Region" {
  default = "us-east-1"
}
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
  
}
variable "subnet_cidr" {
    type = list(string)
    default = ["10.0.8.0/24", "10.0.9.0/24", "10.0.10.0/24"]
}
# Declare the data source
data "aws_availability_zones" "azs" {}
