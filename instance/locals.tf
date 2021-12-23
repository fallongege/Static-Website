locals {
  ami           = lookup(var.ami_id, var.terraform_Env)
  region        = var.region
  instance_type = lookup(var.instance_type, var.terraform_Env)

  tags = lookup(var.mandatory_tags, var.terraform_Env)
}