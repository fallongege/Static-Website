variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "vpc_id" {
}

variable "gateway_id" {
  
}
variable "subnet1_cidr" {
  type    = string
  default = "10.0.0.0/24"
}
variable "subnet1_id" {
  
}
variable "subnet2_id" {
  
}

variable "az1" {
  type    = string
  default = "us-east-1a"
}
variable "subnet2_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
variable "az2" {
  type    = string
  default = "us-east-1b"
}

variable "serverport1" {
  type    = number
  default = 443
}
variable "serverport2" {
    type = number
    default = 80
  
}

