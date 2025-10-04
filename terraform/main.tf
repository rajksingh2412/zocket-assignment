provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "task_tracker" {
  ami           = "ami-0a0ad6b70e61be944"  # Ubuntu 22.04 LTS for ap-south-1
  instance_type = "t2.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.task_sg.id]

  tags = {
    Name = "task-tracker"
  }

  # Install Docker via user_data
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io curl wget

              systemctl enable docker
              systemctl start docker


              # Install Node Exporter for monitoring
              useradd -m -s /bin/false nodeusr
              cd /opt
              wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
              tar xvf node_exporter-*.tar.gz
              cp node_exporter-*/node_exporter /usr/local/bin/
              chown nodeusr:nodeusr /usr/local/bin/node_exporter

              # Create systemd service
              cat <<EOL > /etc/systemd/system/node_exporter.service
              [Unit]
              Description=Node Exporter
              After=network.target

              [Service]
              User=nodeusr
              Group=nodeusr
              Type=simple
              ExecStart=/usr/local/bin/node_exporter

              [Install]
              WantedBy=default.target
              EOL

              systemctl daemon-reexec
              systemctl daemon-reload
              systemctl enable node_exporter
              systemctl start node_exporter
              EOF

}

resource "aws_security_group" "task_sg" {
  name        = "task-tracker-sg"
  description = "Allow web traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.bucket_name}"
  force_destroy = true
}
