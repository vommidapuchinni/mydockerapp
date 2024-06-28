Step 1: Launch an EC2 Instance
1.	Launch an EC2 Instance:
2.	Go to the AWS Management Console.
3.	Navigate to the EC2 Dashboard.
4.	Click on "Launch Instance".
5.	Choose the ubuntu as AMI.
6.	Select the t2.micro instance type.
7.	Create and download the key pair and save it securely
8.	Configure the instance details.
9.	Add storage (default 8 GB).
10.	Configure the security group choose all traffic anywhere.
11.	Launch the instance.

Step 2: Install needed packages

1.	Java: apt install default-jdk -y
2.	Awscli: apt install unzip -y && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
3.	maven: apt install maven -y
4.	Jenkins: sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
                 https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
                 echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
                https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
               /etc/apt/sources.list.d/jenkins.list > /dev/null
                 sudo apt-get update && sudo apt-get install jenkins 
5.	Docker: apt install docker.io -y
6.	Docker-compose: sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
7.	Terraform: 
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add –
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
terraform -v

step3: Dockerfile

FROM tomcat:10-jdk17
COPY ./target/MyWebApp.war /usr/local/tomcat/webapps
EXPOSE 8080
CMD ["catalina.sh", "run"]

Step 4: Jenkins pipeline

pipeline {
    agent any
    environment{
        DOCKERHUB_CREDENTIALS =credentials('docker-hub')
    }
    stages {
        stage('Clone') {
            steps {
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/vommidapuchinni/mydockerapp.git']])
            }
        }
        stage('validate'){
            steps{
                sh 'mvn validate'
            }
        }
        stage('Compile'){
           steps{
               sh 'mvn compile' 
           }
        }
        stage('test'){
            steps{
                sh 'mvn test'
            }
        }
        stage('package'){
            steps{
                sh 'mvn package'
            }
        }
        stage('build docker image'){
            steps{
                sh 'docker build -t chinni111/tomcat:$BUILD_NUMBER .'
            }   
        }
        stage('Login to DockerHub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        stage('push image'){
            steps{
                sh 'docker push chinni111/tomcat:$BUILD_NUMBER'
            }
        }
        stage('docker-compose'){
            steps{
                sh'docker-compose up'
            }
        }
    }
}

step 5: Deployment 
deployed to AWS ECS

provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-ecs-cluster"
}
resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = "my-task-family"
  container_definitions    = <<EOF
[
  {
    "name": "my-container",
    "image": "chinni111/tomcat:3",
    "cpu": 256,
    "memory": 512
  }
]
EOF
}
resource "aws_ecs_service" "my_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1
}

Go to aws ECS in that task definition we see there our container

step 6:  Monitoring and logging

using node_exporter, prometheus and grafana we observe our docker system monitoring

install node_exporter, prometheus and grafana on our server make sure both should be on running
Access node_exporter using localhost:9100
Access node_exporter using localhost:9090
Access node_exporter using localhost:3000
