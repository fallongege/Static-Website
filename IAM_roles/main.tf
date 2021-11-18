provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "ec2s3role" {
  name               = "EC2_S3_Role"
  assume_role_policy = file("ec2-assume-policy.json")
}
resource "aws_iam_role_policy" "ec2s3policy" {
  name   = "EC2-S3-Policy"
  role   = aws_iam_role.ec2s3role.name
  policy = file("ec2-policy.json")
}
resource "aws_iam_instance_profile" "ec2s3profile" {
  name = "EC2-S3-Profile"
  role = aws_iam_role.ec2s3role.name
}
data "aws_subnet" "satinstance" {
  filter {
    name   = "tag:Name"
    values = ["SSMsubnet"]
  }
}
data "aws_security_group" "satinstanceSG" {
  id = "sg-0880e9871044f63dc"

}

resource "aws_instance" "jjtechserver" {
  ami                         = "ami-04ad2567c9e3d7893"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnet.satinstance.id
  key_name                    = "myKeypair"
  vpc_security_group_ids      = [data.aws_security_group.satinstanceSG.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2s3profile.id

  tags = {
    Name = "Sat-Workshop-Server"
  }
}