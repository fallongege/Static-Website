resource "aws_instance" "Testserver" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  count = "${var.ec2_count}"

  tags = {
    Name = "Test-Server"
  }
}