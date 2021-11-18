#Craeting an EC2 role to access s3 service
resource "aws_iam_role" "ec2rolefors3" {
  name               = "ec2_role_for_s3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy" "ec2fors3policy" {
  name   = "ec2fors3policy"
  role = aws_iam_role.ec2rolefors3.name
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
         "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
})
}
resource "aws_iam_instance_profile" "ec2s3role" {
  name = "Ec2-Role-S3"
  role = aws_iam_role.ec2rolefors3.name
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
  key_name                    = "mykeypar"
  vpc_security_group_ids      = [data.aws_security_group.satinstanceSG.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2s3role.id

  tags = {
    Name = "Sat-Workshop-Server"
  }
}