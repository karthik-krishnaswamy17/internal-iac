#!/bin/bash
remote_host="f24c46691b3c.mylabserver.com"
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
else
    echo "Remote Server not-online.Start manually"
    exit 
fi
