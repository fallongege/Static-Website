# vpc cidr
variable "vpccidr" {
  type    = string
  default = "10.0.0.0/16"
}
#Availability Zones-1
variable "Az1" {
  type    = string
  default = "us-east-1a"

}
#Availability Zones-2
variable "Az2" {
  type    = string
  default = "us-east-1b"

}
# Web Public subnet-1 Cidr
variable "web-pub-subnt-1Cidr" {
  type    = string
  default = "10.0.0.0/24"
}
# Web Public subnet-2 Cidr
variable "web-pub-subnt-2Cidr" {
  type    = string
  default = "10.0.1.0/24"
}
# App Private subnet-1 Cidr
variable "app-prvt-subnt-1Cidr" {
  type    = string
  default = "10.0.2.0/24"
}
# App Private subnet-2 Cidr
variable "app-prvt-subnt-2Cidr" {
  type    = string
  default = "10.0.3.0/24"
}
# Database Private subnet-1 Cidr
variable "database-prvt-subnt-1Cidr" {
  type    = string
  default = "10.0.4.0/24"
}
# Database Private subnet-2 Cidr
variable "database-prvt-subnt-2Cidr" {
  type    = string
  default = "10.0.5.0/24"
}
variable "port80" {
  type    = number
  default = 80

}
variable "port22" {
  type    = number
  default = 22

}
variable "port3306" {
  type    = number
  default = 3306

}
variable "instancetype" {
  type    = string
  default = "t2.micro"
}
variable "Keypair" {
  type    = string
  default = "shared-prd-nonprd-nova"
}
variable "enter-password" {

}
