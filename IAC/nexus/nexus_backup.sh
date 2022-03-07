#!/bin/bash
remote_host=f24c46691b3c.mylabserver.com
cd /home/ubuntu
sudo tar zcf nexus-persistence.tar.gz nexus-persistence
scp -o StrictHostKeyChecking=no nexus-persistence.tar.gz cloud_user@${remote_host}:/home/cloud_user/remote_files
