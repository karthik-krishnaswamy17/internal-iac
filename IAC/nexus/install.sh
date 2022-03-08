#!/bin/sh
# remote_host=f24c46691b3c.mylabserver.com
remote_host=${1}
sudo apt-get update -y
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-key fingerprint 0EBFCD88
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y 
sudo usermod -aG docker ubuntu
sudo apt install sshpass -y 
if [ -f /home/ubuntu/.ssh/id_rsa ] | [ -f /home/ubuntu/.ssh/id_rsa.pub ]
then
  rm -rf /home/ubuntu/.ssh/id_rsa 2>/dev/null
  rm -rf /home/ubuntu/.ssh/id_rsa.pub 2>/dev/null
fi
ssh-keygen -b 2048 -t rsa -f /home/ubuntu/.ssh/id_rsa -q -N ""
cat /home/ubuntu/.ssh/id_rsa.pub  | sshpass -p devops90! ssh -o StrictHostKeyChecking=no cloud_user@${remote_host} "cat >> /home/cloud_user/.ssh/authorized_keys"

# git clone https://github.com/karthik-krishnaswamy17/internal-iac.git
mkdir -p /home/ubuntu/internal-iac/IAC/nexus
cd /home/ubuntu/internal-iac/IAC/nexus
cat > nexus_backup.sh <<EOF
#!/bin/bash
cd /home/ubuntu
sudo tar zcf nexus-persistence.tar.gz nexus-persistence
scp -o StrictHostKeyChecking=no nexus-persistence.tar.gz cloud_user@${remote_host}:/home/cloud_user/remote_files
EOF
sudo chmod u+x nexus_backup.sh

crontab -l > nexus_backup_cron
echo " */30 * * *  * /home/ubuntu/internal-iac/IAC/nexus/nexus_backup.sh" >> nexus_backup_cron
crontab  nexus_backup_cron
rm  nexus_backup_cron

mkdir -p /home/ubuntu/remote_files
sudo chown -R ubuntu:ubuntu /home/ubuntu/remote_files/
mkdir -p /home/ubuntu/nexus-persistence
sudo chown -R 200:200 /home/ubuntu/nexus-persistence

scp -r -o StrictHostKeyChecking=no cloud_user@${remote_host}:/home/cloud_user/remote_files/nexus-persistence.tar.gz /home/ubuntu/remote_files/nexus-persistence.tar.gz
cd /home/ubuntu
sudo tar xf /home/ubuntu/remote_files/nexus-persistence.tar.gz

sudo docker run --name nexus -d -p 8081:8081  --volume /home/ubuntu/nexus-persistence:/nexus-data sonatype/nexus3
