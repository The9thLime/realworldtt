resource "aws_db_instance" "app-database" {
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp3"
  engine               = "mysql"
  engine_version       = "8.0.35"
  db_name              = "realworld"
  identifier           = "realworld" # Ensure this is unique
  username             = "admin"
  password             = "slime123" # Consider using AWS Secrets Manager
  db_subnet_group_name = aws_db_subnet_group.database-subnet-group.name
  skip_final_snapshot  = true
}

resource "aws_db_subnet_group" "database-subnet-group" {
  name = "database-subnet-group"
  subnet_ids = [
    aws_subnet.subnets["ap-south-1a"].id,
    aws_subnet.subnets["ap-south-1b"].id
  ]
}
