#!/bin/bash
remote_host=f24c46691b3c.mylabserver.com
jenkins(){
    cd ~/Desktop/Devops/Practise_Devops/IAC/jenkins
    terraform destroy -var remote_host=${remote_host}  -auto-approve > jenkins.log 2>&1 &
}


sonarqube(){
    cd ~/Desktop/Devops/Practise_Devops/IAC/sonarQube
    terraform  destroy -var remote_host=${remote_host}  -auto-approve > sonarqube.log 2>&1 &
}

nexus(){
    cd ~/Desktop/Devops/Practise_Devops/IAC/nexus
    terraform  destroy -var remote_host=${remote_host} -auto-approve > nexus.log 2>&1 &
}

case $1 in
s) sonarqube ;;
j) jenkins ;;
n) nexus ;;
sjn) 
sonarqube
jenkins
nexus
;;
*)
echo "Invalid Option.."
echo "Use j for jenkins. 
use s for SonarQube. use n for Nexus
use sjn for all."
esac

