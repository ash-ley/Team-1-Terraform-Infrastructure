resource "aws_security_group" "private_elasticsearch_sg" {
  vpc_id = module.network.my_vpc_id

  # INBOUND RULES

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "elasticsearch port"
    from_port   = 9200
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  #OUTBOUND RULES

  egress {
    description = "Allow access to the world"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_server_sg"
  }
}


resource "aws_instance" "elasticsearch_server" {
  ami                    = "ami-07d8796a2b0f8d29c"
  subnet_id              = module.network.private_subnet_a_id
  instance_type          = "t2.medium"
  key_name               = "Team1KeyPair"
  vpc_security_group_ids = [aws_security_group.private_elasticsearch_sg.id]
  tags = {
    Name = "elasticsearch-server"
  }
}