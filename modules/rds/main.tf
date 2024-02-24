resource "aws_db_instance" "db_instance" {

  engine                  = "mysql"
  engine_version          = "5.7"
  multi_az                = false
  identifier              = var.db_instance_identifier
  username                = var.db_username
  password                = var.db_password
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = var.vpc_security_group_ids
  availability_zone       = var.availability_zone
  db_name                 = var.db_name
  skip_final_snapshot     = var.skip_final_snapshot
}

