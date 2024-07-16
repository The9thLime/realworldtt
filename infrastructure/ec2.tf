resource "aws_instance" "mainInstance" {
  ami             = "ami-0ec0e125bb6c6e8ec"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.main["ap-south-1a"].id
  security_groups = [aws_security_group.instanceSG.id]
}

