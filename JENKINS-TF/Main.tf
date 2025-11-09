resource "aws_security_group" "Jenkins-sg" {
  name        = "Jenkins_Security_Group"
  description = "Open 22,443,80,8080,9000,9090,3001,9100,8081"

  # single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000, 9090, 3001, 9100, 8081] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-sg"
  }
}


resource "aws_instance" "web" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.small"
  key_name               = "Texas"
  vpc_security_group_ids = [aws_security_group.Jenkins-sg.id]
  user_data              = templatefile("./install_monitoring.sh", {})

  tags = {
    Name = "Monitoring-Server"
  }
  root_block_device {
    volume_size = 12
  }
}



