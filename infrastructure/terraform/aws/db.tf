resource "aws_db_instance" "myDB" {
  instance_class            = "db.t3.micro"
  allocated_storage         = 20
  storage_type              = "gp3"
  engine                    = "mysql"
  engine_version            = "8.0.35"
  db_name                   = "myDB"
  identifier                = "mydatabase" # Ensure this is unique
  username                  = "admin"
  password                  = "slime123" # Consider using AWS Secrets Manager
  db_subnet_group_name      = aws_db_subnet_group.DB_Subnet_Group.name
  snapshot_identifier       = "foo"
  skip_final_snapshot       = true
}

resource "aws_db_subnet_group" "DB_Subnet_Group" {
  name = "my-db-subnet-group"
  subnet_ids = [
    aws_subnet.main["ap-south-1a"].id,
    aws_subnet.main["ap-south-1b"].id
  ]
}
