
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.prod-subnet-private-1.id, aws_subnet.prod-subnet-private-2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "mysql_database_security_group" {
  name        = "database-security-group"
  description = "Allow access to  MySQL database from private network."
  vpc_id      = aws_vpc.prod-vpc.id


  ingress {
    from_port       = var.database_port
    to_port         = var.database_port
    protocol        = "tcp"
    security_groups = ["${aws_security_group.WebServersSecGroup.id}"]
  }
}


resource "aws_db_instance" "default" {
  allocated_storage        = 10
  engine                   = "mysql"
  engine_version           = "5.7"
  instance_class           = "db.t3.micro"
  identifier               = "clarusway"
  name                     = var.database_name
  username                 = var.database_user
  password                 = var.database_password
  port                     = var.database_port
  vpc_security_group_ids   = ["${aws_security_group.mysql_database_security_group.id}"]
  db_subnet_group_name     = aws_db_subnet_group.default.name
  delete_automated_backups = true
  skip_final_snapshot      = true
}

output "rds_endpoint" {
  value = aws_db_instance.default.address
}




