variable "port1" {
  type    = number
  default = 80
}
variable "port2" {
  type    = number
  default = 22
}

variable "KeyPair" {
  type = string
  default = "shared-prd-nonprd-nova"

}
