module "instance_in_module" {
  source        = "../modules/ec2"
  REGION        = local.region
  ami_id        = local.ami
  instance_type = local.instance_type
  tags = local.tags
}



