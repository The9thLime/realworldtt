resource "aws_db_instance" "myDB" {
  instance_class       = "db.t2.micro"
  allocated_storage    = 5
  storage_type         = "gp3"
  engine               = "mysql"
  engine_version       = "8.0.35"
  db_name              = "myDB"
  identifier           = "mydatabse"
  username             = "admin"
  password             = "123"
  db_subnet_group_name = aws_db_subnet_group.DB_Subnet_Group.id
}

resource "aws_db_subnet_group" "DB_Subnet_Group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.main["ap-south-1a"].id]
}