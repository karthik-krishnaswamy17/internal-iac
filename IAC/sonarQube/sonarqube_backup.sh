#!/bin/bash
remote_host=f24c46691b3c.mylabserver.com
cd /home/ubuntu
sudo tar zcf sonarqube-persistence.tar.gz sonarqube-persistence
scp -o StrictHostKeyChecking=no sonarqube-persistence.tar.gz cloud_user@${remote_host}:/home/cloud_user/remote_files