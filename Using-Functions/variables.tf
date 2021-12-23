variable "vpccidr" {
  default = "192.168.0.0/16"

}
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}
variable "intance_count" {
  default = 2
}
variable "ami_ids" {
  default = {
    "us-east-1" = "ami-04ad2567c9e3d7893"
    "us-east-2" = "ami-0dd0ccab7e2801812"
  }

}