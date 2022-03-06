#!/bin/bash
cd /var/lib
sudo tar zcf jenkins.tar.gz jenkins
scp -o StrictHostKeyChecking=no jenkins.tar.gz cloud_user@f24c46691b3c.mylabserver.com:/home/cloud_user/remote_files
