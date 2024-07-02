provider "aws" {
  region = "us-east-1" # Substitua pela sua região preferida
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" 

  tags = {
    Name = "main_subnet"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main_rt"
  }
}

resource "aws_route_table_association" "main_rta" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_rt.id
}

resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main_sg"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "main_ec2" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.main_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Definindo variáveis de ambiente
              DB_NAME='testdb'
              DB_USER='postgres'
              DB_PASSWORD='yourpassword'
              DB_HOST='localhost'
              DB_PORT='5432'
              
              # Exportando variáveis de ambiente
              echo "export DB_NAME=testdb" >> /etc/environment
              echo "export DB_USER=postgres" >> /etc/environment
              echo "export DB_PASSWORD=yourpassword" >> /etc/environment
              echo "export DB_HOST=localhost" >> /etc/environment
              echo "export DB_PORT=5432" >> /etc/environment
              
              # Atualizando e instalando pacotes necessários
              sudo yum update -y
              sudo yum install -y python3
              sudo pip3 install boto3
              sudo amazon-linux-extras install -y postgresql13
			  sudo yum install postgresql-server -y
              sudo yum install -y docker
              sudo systemctl start postgresql
              sudo systemctl enable postgresql
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -a -G docker ec2-user

              # Instalando git para clonar o repositório
              sudo yum install git -y

              # Clonando o repositório com o Dockerfile, o código PHP e o iniciador do banco de dados
              git clone https://github.com/Joaofranciscopanta/Case-DevOps-I /home/ec2-user

              # Construindo e executando o contêiner Docker
              cd /home/ec2-user/Case-DevOps-I
              sudo docker build -t my-php-app .
              sudo docker run -d -p 80:80 my-php-app
			  
			  # Cronjob de backup
			  echo "0 2 * * * /usr/bin/python3 /home/ec2-user/Case-DevOps-I/backup_script.py" > /etc/cron.d/backup

              EOF

  tags = {
    Name = "main_ec2"
  }
}

resource "aws_s3_bucket" "main_bucket" {
  bucket = "backupbucketaaaaax" 

  tags = {
    Name = "main_bucket"
  }
}