output "instance_public_ip" {
  value = module.instance_in_module.public_ip
}
output "instance_arn" {
  value = module.instance_in_module.instanceArn
}