#!/bin/bash

remote_host=${cloud_server}
run_job()
{
    jenkins(){
        cd ~/Desktop/Devops/Practise_Devops/IAC/jenkins
        if [ -f jenkins.log ]
        then
        rm -rf jenkins.log terraform.tfstate terraform.tfstate.backup 2>/dev/null
        fi
        terraform apply -var remote_host=${remote_host} -auto-approve > jenkins.log 2>&1 &
    }


    sonarqube(){
        cd ~/Desktop/Devops/Practise_Devops/IAC/sonarQube
        if [ -f sonarQube.log ]
        then
        rm -rf sonarQube.log terraform.tfstate terraform.tfstate.backup 2>/dev/null
        fi
        terraform  apply -var remote_host=${remote_host} -auto-approve > sonarqube.log 2>&1 &
    }

    nexus(){
        cd ~/Desktop/Devops/Practise_Devops/IAC/nexus
        if [ -f nexus.log ]
        then
        rm -rf nexus.log terraform.tfstate terraform.tfstate.backup 2>/dev/null
        fi
        terraform  apply -var remote_host=${remote_host} -auto-approve > nexus.log 2>&1 &
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
}


if nc -z $remote_host 22 2>/dev/null; then
    run_job $1
    sleep 6m
    ##SonarCube
    sonar_public_ip=$(cat /home/karthik/Desktop/Devops/Practise_Devops/IAC/sonarQube/public_ip.txt)
    sonar_private_ip=$(cat /home/karthik/Desktop/Devops/Practise_Devops/IAC/sonarQube/private_ip.txt)
    ##Jenkins
    jenkins_public_ip=$(cat /home/karthik/Desktop/Devops/Practise_Devops/IAC/jenkins/public_ip.txt)
    jenkins_private_ip=$(cat /home/karthik/Desktop/Devops/Practise_Devops/IAC/jenkins/private_ip.txt) 
    ##Jenkins
    nexus_public_ip=$(cat /home/karthik/Desktop/Devops/Practise_Devops/IAC/nexus/public_ip.txt)
    nexus_private_ip=$(cat /home/karthik/Desktop/Devops/Practise_Devops/IAC/nexus/private_ip.txt) 

    echo -e "${sonar_private_ip} sonarqube\n${jenkins_private_ip} jenkins\n${nexus_private_ip} nexus" | ssh -o ConnectTimeout=900 -o StrictHostKeyChecking=no -i /home/karthik/.ssh/id_rsa ubuntu@${sonar_public_ip} "sudo tee -a /etc/hosts"
    echo -e "${sonar_private_ip} sonarqube\n${jenkins_private_ip} jenkins\n${nexus_private_ip} nexus" | ssh -o ConnectTimeout=900 -o StrictHostKeyChecking=no -i /home/karthik/.ssh/id_rsa ubuntu@${jenkins_public_ip} "sudo tee -a /etc/hosts"
    echo -e "${sonar_private_ip} sonarqube\n${jenkins_private_ip} jenkins\n${nexus_private_ip} nexus" | ssh -o ConnectTimeout=900 -o StrictHostKeyChecking=no -i /home/karthik/.ssh/id_rsa ubuntu@${nexus_public_ip} "sudo tee -a /etc/hosts"
else
    echo "Remote Server not-online.Start manually"
    exit 
fi

