# Lookup vcp in my aws account
data "aws_vpc" "myvpc" {
  filter {
    name   = "tag:Name"
    values = ["Dev-vpc"]
  }
}

#Lookup subnet ids in my aws account
data "aws_subnet" "mysubnet1" {
  filter {
    name   = "tag:Name"
    values = ["Dev-Subnet1"]
  }
}

data "aws_subnet" "mysubnet2" {
  filter {
    name   = "tag:Name"
    values = ["Dev-Subnet2"]
  }
}
# Create Securiity Group
resource "aws_security_group" "alb-SG" {
  name        = "alb-SG"
  description = "Allow HTTP and SSH inbound traffic"
  ingress {
    description = "HTTP for ALB"
    from_port   = var.port1
    to_port     = var.port1
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH for ALB"
    from_port   = var.port2
    to_port     = var.port2
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ALB-Security-Group"
  }
}

#Create Application Load Balancer
resource "aws_lb" "DevAlb" {
  name                       = "prod-ALB"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [data.aws_subnet.mysubnet1.id, data.aws_subnet.mysubnet2.id]
  enable_deletion_protection = false

  tags = {
    Name = "Dev-application-load-balancer"
  }
}

# Create Target group for ALB
resource "aws_lb_target_group" "DevAlbTarGrp" {
  name        = "Dev-Alb-Traget-Group"
  port        = var.port1
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.myvpc.id

  health_check {

    healthy_threshold   = 6
    interval            = 15
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 2
  }
}

# Create Listner for Dev ALB for port 80
resource "aws_lb_listener" "DevAlb-listner_Http" {
  load_balancer_arn = aws_lb.DevAlb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arns = [aws_lb_target_group.DevAlbTarGrp.arn]
  }
}

# Launch configuration for Autoscaling
data "aws_ami" "amazon-linux2" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "Dev_launch_Config" {
  name          = "Dev_launch_Config"
  image_id      = data.aws_ami.amazon-linux2.id
  instance_type = "t2.micro"
  key_name      = var.KeyPair
  user_data     = <<-EOF
             #!/bin/bash
             sudo su
             yum update -y
             yum install -y httpd
             systemctl start httpd.service
             systemctl enable httpd.service
             echo "hello from server 1" > /var/www/html/index.html
             EOF

  lifecycle {
    create_before_destroy = true
  }
}

#Create an Auto Scaling group
resource "aws_autoscaling_group" "DevAutoGrp" {
  name                      = "Dev_Auto_scaling_grp"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.Dev_launch_Config.name
  vpc_zone_identifier       = [data.aws_subnet.mysubnet1.id, data.aws_subnet.mysubnet2.id]
  target_group_arns          = [aws_lb_target_group.DevAlbTarGrp.arn]

 

  tag {
    key                 = "Name"
    value               = "DevAutoScaling"
    propagate_at_launch = true
  }
}

#Define a AutoScaling Group Scale-Up Policy and Associated CloudWatch Metric Alarm
#.....This policy triggers the scale-up of instances when the group’s overall memory utilization is >= 80% for '2' 5-minute intervals
resource "aws_autoscaling_policy" "policy1" {
  name                   = "Dev_ASG_ScaleUp_Policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.DevAutoGrp.name
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "Dev_CPU_Scale_Up_Alarm" {
  alarm_name          = "Dev_CPU_Scale_Out_Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.DevAutoGrp.name
  }
}
#Define a AutoScaling Group Scale-Down Policy and CloudWatch Metric Alarm
#......This triggers the scale-down of instances when the group’s overall memory utilization is <= 40% for '2' 2-minute intervals
resource "aws_autoscaling_policy" "policy2" {
  name                   = "Dev_ASG_ScaleDown_Policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.DevAutoGrp.name
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "Dev_CPU_Scale_Out_Alarm" {
  alarm_name          = "Dev_CPU_Scale_Out_Alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "120"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.DevAutoGrp.name
  }
}

output "subnet_id" {
  value = data.aws_vpc.myvpc.id
}
 