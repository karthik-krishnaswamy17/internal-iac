#!/bin/sh
# remote_host=f24c46691b3c.mylabserver.com
remote_host=${1}
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get update 
sudo apt install openjdk-11-jdk -y 
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo apt install sshpass -y 
if [ -f /home/ubuntu/.ssh/id_rsa ] | [ -f /home/ubuntu/.ssh/id_rsa.pub ]
then
  rm -rf /home/ubuntu/.ssh/id_rsa 2>/dev/null
  rm -rf /home/ubuntu/.ssh/id_rsa.pub 2>/dev/null
fi
ssh-keygen -b 2048 -t rsa -f /home/ubuntu/.ssh/id_rsa -q -N ""
#cat /home/ubuntu/.ssh/id_rsa.pub | sshpass -p devops90! ssh cloud_user@f24c46691b3c.mylabserver.com 'umask 077; cat >>.ssh/authorized_keys'
cat /home/ubuntu/.ssh/id_rsa.pub  | sshpass -p devops90! ssh -o StrictHostKeyChecking=no cloud_user@${remote_host} "cat >> /home/cloud_user/.ssh/authorized_keys"

#sshpass -p devops90 scp -o StrictHostKeyChecking=no -r /home/ubuntu/.ssh/id_rsa.pub ubuntu@${remote_host}:/home/ubuntu/.ssh/authorized_keys 

# sshpass -p devops90! ssh-copy-id -i /home/ubuntu/.ssh/id_rsa.pub -f ubuntu@${remote_host} -o StrictHostKeyChecking=no

git clone https://github.com/karthik-krishnaswamy17/internal-iac.git
cd /home/ubuntu/internal-iac/IAC/jenkins
sudo chmod u+x jenkins_backup.sh
crontab -l > jenkins_backup_cron
echo " */30 * * *  * /home/ubuntu/internal-iac/IAC/jenkins/jenkins_backup.sh " >> jenkins_backup_cron
crontab  jenkins_backup_cron
rm  jenkins_backup_cron

mkdir -p /home/ubuntu/remote_files
sudo chown -R ubuntu:ubuntu /home/ubuntu/remote_files/

scp -r -o StrictHostKeyChecking=no cloud_user@${remote_host}:/home/cloud_user/remote_files/jenkins.tar.gz /home/ubuntu/remote_files/jenkins.tar.gz
cd /var/lib/
sudo tar xf /home/ubuntu/remote_files/jenkins.tar.gz
sudo systemctl restart jenkins
