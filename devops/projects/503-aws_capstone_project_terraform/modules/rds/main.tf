#------ rds/main.tf ---

resource "aws_db_instance" "aws_capstone_db" {
  allocated_storage       = var.db_storage
  engine                  = var.engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  name                    = var.dbname
  username                = var.dbuser
  password                = var.dbpassword
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = var.vpc_security_group_ids
  identifier              = var.db_identifier
  skip_final_snapshot     = var.skip_db_snapshot
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  deletion_protection     = var.deletion_protection
  tags = {
    Name = "aws-capstone-db"
  }
}