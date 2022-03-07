terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

variable "remote_host" {}

provider "aws" {
#   access_key = "my-access-key"
#   secret_key = "my-secret-key"
  region     = "us-east-1"
}


resource "aws_security_group" "aws_sg_sonar" {
  name = "sg for sonar"

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "80 from the internet"
    from_port   = 9000
    to_port     = 9000
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
resource "aws_key_pair" "ssh-key-pair" {
  key_name="ssh-key-pair-sonar"
  public_key = "${file("/home/karthik/.ssh/id_rsa.pub")}"
}


resource "aws_instance" "aws_ec2" {
 
  ami                         = "ami-04505e74c0741db8d"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.aws_sg_sonar.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key-pair.id
  #user_data = "${file("install.sh")}"
  tags = {
    Name = "SonarQube"
  }
  root_block_device {
    volume_size="20"
  }
  connection {
    # The default username for our AMI
    
    user        = "ubuntu"
    host        = self.public_ip
    type        = "ssh"
    private_key = file("/home/karthik/.ssh/id_rsa")
    
  }

  provisioner "file" {
    source      = "install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh ${var.remote_host}",  

    ]
  }

provisioner "local-exec" {
  command =  <<-EOT
  sudo cp /etc/hosts /etc/hosts_bkp
  sudo sed -i 's/.*sonarqube.*/${self.public_ip} sonarqube/g' /etc/hosts
  sudo sed -i 's/.*server.*/server=${self.public_ip}/g' /home/karthik/Desktop/Devops/remmina/sonarqube.remmina
  sudo echo ${self.private_ip} > /home/karthik/Desktop/Devops/Practise_Devops/IAC/sonarQube/private_ip.txt
  sudo echo ${self.public_ip} > /home/karthik/Desktop/Devops/Practise_Devops/IAC/sonarQube/public_ip.txt
  sudo kill -9 `pidof remmina`
  EOT
  
}
}

output "instance_ip" {
  value = aws_instance.aws_ec2.public_ip
}