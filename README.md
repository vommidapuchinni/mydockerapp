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
