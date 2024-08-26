resource "aws_instance" "jenkins-instance" {
  ami             = "ami-0ec0e125bb6c6e8ec"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnets["ap-south-1a"].id
  security_groups = [aws_security_group.instance-sg.id]

}