

#!/bin/bash



#INSTALL JENKINS

 sudo yum update –y
 sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
 sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
 sudo yum upgrade -y
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
 sudo systemctl start jenkins
 sudo systemctl status jenkins

#INSTALL GIT 

sudo yum install git-y



#INSTALL TERRAFORM

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform



#INSTALL Kubectl

sudo curl -LO https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl





