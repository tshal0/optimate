# --- rds/rds.tf ---



# DB Subnet Group

resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

#create a RDS Database Instance
resource "aws_db_instance" "db" {
  engine                 = "mysql"
  identifier             = "${var.app_name}-rds"
  allocated_storage      = 10
  instance_class         = "db.t2.micro"
  availability_zone      = "us-east-2a"
  username               = var.db_user
  password               = var.db_pass
  parameter_group_name   = "default.mysql8.0"
  vpc_security_group_ids = [var.rds_sg]
  skip_final_snapshot    = true
  publicly_accessible    = false
  apply_immediately      = false

  db_subnet_group_name = aws_db_subnet_group.main.id
}
