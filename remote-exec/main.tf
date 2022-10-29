resource "aws_instance" "first-ec2" {
  ami           = "ami-09d3b3274b6c5d4aa" 
  instance_type = "t2.micro"
  key_name 		= "jenkinsKey"
  security_groups = ["jenkins-ssh-sg"]
  tags = {
    Name = "devops"
  }
  
  connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = file("key.pem")
      #host = aws_instance.web.public_ip
      host = aws_instance.first-ec2.public_ip
  }
  provisioner "remote-exec" {
    inline = [
	  "sudo yum update -y",
    "sudo yum install httpd -y",
	  "sudo systemctl start httpd",
    "sudo systemctl enable httpd",
    ]
  }
}
