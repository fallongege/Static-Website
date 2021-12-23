variable "region" {  
    type = string 
    default = "us-east-1"
}
variable "ami_id" {
    type = map(string)
    default = {
      "prod" = "ami-0ed9277fb7eb570c9"
      "stg" = "ami-0ed9277fb7eb570c9"
      "dev" = "ami-0ed9277fb7eb570c9"
    }
}
variable "instance_type" {
    type = map(string)
    default = {
      "prod" = "t2.micro"
      "stg" = "t2.small"
      "dev" = "t2.medium"
           } 
}

variable "terraform_Env" {
  type = string
}

variable "mandatory_tags" {
    type = map(map(string))
    default = {
      
      "prod" = {
        "Env" = "prod"
        "Name" = "prod"
      }
       "stg" = {
        "Env" = "stg"
        "Name" = "staging"
      }
       "dev" = {
        "Env" = "dev"
        "Name" = "development"
      }
    }
}
