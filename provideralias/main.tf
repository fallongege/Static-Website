provider "aws" {
  region = "us-east-1"
  alias  = "east"
}
provider "aws" {
  region = "us-west-1"
  alias  = "west"
}


resource "aws_instance" "eastweb" {
  ami           = "ami-0ed9277fb7eb570c9"
  instance_type = "t2.micro"
  provider      = aws.east

  tags = {
    Name = "EastInstance"
  }
}

resource "aws_instance" "westweb" {
  ami           = "ami-03af6a70ccd8cb578"
  instance_type = "t2.micro"
  provider      = aws.west

  tags = {
    Name = "WestInstsnce"
  }
}