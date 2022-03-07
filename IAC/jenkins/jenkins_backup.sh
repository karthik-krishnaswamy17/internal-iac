#!/bin/bash
remote_host=f24c46691b3c.mylabserver.com
cd /home/ubuntu
sudo tar zcf jenkins-persistence.tar.gz jenkins-persistence
scp -o StrictHostKeyChecking=no jenkins-persistence.tar.gz cloud_user@${remote_host}:/home/cloud_user/remote_files