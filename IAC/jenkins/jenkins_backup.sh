#!/bin/bash
remote_host=f24c46691b3c.mylabserver.com
cd /var/lib
sudo tar zcf jenkins.tar.gz jenkins
scp -o StrictHostKeyChecking=no jenkins.tar.gz cloud_user@${remote_host}:/home/cloud_user/remote_files
