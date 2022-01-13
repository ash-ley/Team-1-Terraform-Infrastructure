module "network" {
  source = "/vpc"
  name = "my_vpc"
  vpc_cidr         = "10.10.0.0/16"
  region           = "eu-west-1"
  vpc_name         = "ELK-Stack-VPC"
  internet_gw_name = "team1-new-INT-GW"
  public_cidr_a    = "10.10.1.0/24"
  private_cidr_a = "10.10.2.0/24"
  private_cidr_b = "10.10.3.0/24"
  enable_nat_gateway  = true
  single_nat_gateway = true
}

resource "aws_security_group" "private_elasticsearch_sg" {
 vpc_id      = module.network.my_vpc_id

  # INBOUND RULES
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    /* put the private subnet cidr  or VPC????*/
    cidr_blocks = ["10.10.2.0/24"]
  }

  ingress {
    description = "elasticsearch port"
    from_port = 9200
    to_port = 9300
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  #OUTBOUND RULES

   egress {
    description = "allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    description = "allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    /* vpc cidr block */
    cidr_blocks = ["10.10.0.0/16"]
  }


  # egress {
  #   description = "Allow access to the world"
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "private_server_sg"
  }
}


resource "aws_instance" "elasticsearch_server" {
  ami             = "ami-07d8796a2b0f8d29c" 
  subnet_id       = module.network.private_a_id
  instance_type   = "t2.medium"
  key_name        = "Team1KeyPair"
  vpc_security_group_ids = [aws_security_group.private_elasticsearch_sg.id]
  tags            = { 
      Name = "elasticsearch-server" 
    }

}