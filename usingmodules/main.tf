provider "aws" {
  region = "us-east-1"
}

module "my_vpc" {
  source       = "../modules/vpcnetwork"
  vpc_cidr     = "10.0.0.0/16"
  vpc_id       = module.my_vpc.vpc_id
  gateway_id   = module.my_vpc.gateway_id
  subnet1_cidr = "10.0.0.0/24"
  subnet1_id   = module.my_vpc.subnet1_id
  az1          = "us-east-1a"
  subnet2_cidr = "10.0.9.0/24"
  subnet2_id   = module.my_vpc.subnet2_id
  az2          = "us-east-1b"
  serverport1  = "443"
  serverport2  = "80"
}
module "my_instances" {
  source  = "../modules/ASGAlb"
  port1   = 80
  port2   = 22
  KeyPair = "shared-prd-nonprd-nova"

}

