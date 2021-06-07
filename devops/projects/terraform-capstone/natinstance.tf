resource "aws_instance" "nat" {
  ami                         = "ami-00a9d4a05375b2763"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.micro"
  key_name                    = "the_doctor"
  vpc_security_group_ids      = ["${aws_security_group.natinstance.id}"]
  subnet_id                   = aws_subnet.prod-subnet-public-1.id
  associate_public_ip_address = true
  source_dest_check           = false

  tags = {
    Name = "VPC NAT"
  }
}

resource "aws_route" "natinstance" {
  route_table_id         = aws_route_table.prod-private-crt.id
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = aws_instance.nat.id
}