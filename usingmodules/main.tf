provider "aws" {
  region = "us-east-1"

}

module "vpc" {
  source                     = "../modules/vpc"
  vpc_cidr                   = "10.2.0.0/16"
  tenancy                    = "default"
  vpc_id                     = module.vpc.vpc_id
  subnet_id                  = module.vpc.subnet_id
  subnet_cidr                = "10.2.0.0/24"
  route_table_id             = module.vpc.route_table_id
  route_table_association_id = module.vpc.route_table_association_id

}

module "ec2" {
  source        = "../modules/ec2"
  ami_id        = "ami-02e136e904f3da870"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.subnet_id
  ec2_count     = "2"


}