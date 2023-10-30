#!/bin/bash
# Update and install necessary packages using YUM package manager

yum upgrade -y
yum install zip wget git yum-utils maven -y

# Creata a tools directory to move all of the tools cli (Owaasp-Zap, Sonarqube-Scanner, etc.) into 
mkdir /tools


# Install Docker-CE
# Add Docker repository and install required Docker components
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y 
sleep 20
systemctl start docker
systemctl enable docker


# Install Jenkins
# Add Jenkins repository, import Jenkins GPG key, and install Jenkins along with dependencies
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
yum install fontconfig java-17-openjdk -y
yum install jenkins -y


## copy over the pipeline config
## set the Jenkins permisions on the pipeline config directory

mkdir /var/lib/jenkins/jobs/Falcon
git clone https://github.com/IntelliBridge/Falcon-IaC.git
cp Falcon-IaC/Pipeline/config.xml /var/lib/jenkins/jobs/Falcon/config.xml
chown jenkins:jenkins -R /var/lib/jenkins/jobs/Falcon

# Start the Jenkins Service
systemctl start jenkins
systemctl enable jenkins

# Download Owasp Zap
# Retrieve Owasp Zap from its official release and extract it
wget -O owasp_zap.tar.gz https://github.com/zaproxy/zaproxy/releases/download/v2.14.0/ZAP_2.14.0_Linux.tar.gz
tar -xvf owasp_zap.tar.gz
mv ZAP_2.14.0 /tools/zap

# Fetch the Jenkins Admin password
echo -e "Jenkins Password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"

# Create SSH keys for the Jenkins user
# This is necessary for Jenkins to establish SSH connections to other servers
sudo -u jenkins ssh-keygen -t rsa -b 3072 -f "/var/lib/jenkins/.ssh/id_rsa" -N ""


# Configure the server for Sonarqube
# Adjust kernel parameters and user limits
sysctl -w vm.max_map_count=524288
sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192

# Install Dockerized Sonarqube
# Run Sonarqube as a Docker container with specific settings
docker run -d --name sonarqube --restart=always -p 9000:9000 sonarqube 
sleep 120 

# Automate the Sonarqube Admin password reset
# Use the Sonarqube API to change the admin password
curl -u admin:admin -X POST "http://localhost:9000/api/users/change_password?login=admin&previousPassword=admin&password=MySonarAdminPassword"


# Download sonarqube-scanner-cli and move it to /tools directory
wget -O sonarscanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip?_gl=1*14x1mjd*_gcl_au*NDA2NjIzNzcyLjE2OTg1Mjc3MDQ.*_ga*MTUyNzU5NTMzLjE2OTg1Mjc3MDQ.*_ga_9JZ0GZ5TC6*MTY5ODUyNzcwMy4xLjAuMTY5ODUyNzc1OC41LjAuMA..
unzip sonarscanner-cli.zip
mv sonar-scanner-5.0.1.3006-linux /tools/sonarscanner
