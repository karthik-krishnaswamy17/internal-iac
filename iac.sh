#!/bin/bash
case $1 in

s)
cd ~/Desktop/Devops/Practise_Devops/IAC/sonarQube
if [ -f sonarQube.log ]
then
rm -rf sonarQube.log terraform.tfstate terraform.tfstate.backup 2>/dev/null
fi
terraform  apply -auto-approve > sonarqube.log 2>&1 &
;;

j)
cd ~/Desktop/Devops/Practise_Devops/IAC/jenkins
if [ -f jenkins.log ]
then
rm -rf jenkins.log terraform.tfstate terraform.tfstate.backup 2>/dev/null
fi
terraform apply -auto-approve > jenkins.log 2>&1 &
;;

*)
echo "Invalid Option.."
echo "Use j for jenkins. use s for SonarQube. use n for Nexus"
esac


