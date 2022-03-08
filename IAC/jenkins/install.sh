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

sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-key fingerprint 0EBFCD88
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y 
sudo usermod -aG docker ubuntu

sudo apt install sshpass -y 

curl https://get.helm.sh/helm-v3.8.0-linux-386.tar.gz -o helm.tar.gz
tar xf helm.tar.gz 
sudo mv linux-386/helm /usr/local/bin/helm
sudo apt-get install unzip -y
helm plugin install https://github.com/datreeio/helm-datree

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

# git clone https://github.com/karthik-krishnaswamy17/internal-iac.git

mkdir -p /home/ubuntu/internal-iac/IAC/jenkins
cd /home/ubuntu/internal-iac/IAC/jenkins
cat > jenkins_backup.sh <<EOF
#!/bin/bash
cd /var/lib
sudo tar zcf jenkins-persistence.tar.gz jenkins
scp -o StrictHostKeyChecking=no jenkins-persistence.tar.gz cloud_user@${remote_host}:/home/cloud_user/remote_files
EOF
sudo chmod u+x jenkins_backup.sh

crontab -l > jenkins_backup_cron
echo " */30 * * *  * /home/ubuntu/internal-iac/IAC/jenkins/jenkins_backup.sh " >> jenkins_backup_cron
crontab  jenkins_backup_cron
rm  jenkins_backup_cron

mkdir -p /home/ubuntu/remote_files
sudo chown -R ubuntu:ubuntu /home/ubuntu/remote_files/

scp -r -o StrictHostKeyChecking=no cloud_user@${remote_host}:/home/cloud_user/remote_files/jenkins-persistence.tar.gz /home/ubuntu/remote_files/jenkins.tar.gz
cd /var/lib/
sudo tar xf /home/ubuntu/remote_files/jenkins.tar.gz
sudo systemctl restart jenkins
