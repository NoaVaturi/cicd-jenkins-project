pipeline {
    agent any

    environment {
        IMAGE_NAME = 'vnoah/flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.GIT_COMMIT}"
        
    }

    
    stages {

        stage('Setup') {
            steps {
                sh 'bash steps.sh'
            }
        }

        stage('Test') {
            steps {
                sh '''
                   source app/env/bin/activate
                    pytest test_app.py
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                sh 'echo ${PASSWORD} | docker login -u ${USERNAME} --password-stdin'}
                echo 'Login successfully'
            }
        }

        stage('Build Docker Image')
        {
            steps
            {
                sh 'docker build -t ${IMAGE_TAG} .'
                echo "Docker image build successfully"
                sh 'docker image ls'
                
            }
        }

        stage('Push Docker Image')
        {
            steps
            {
                sh 'docker push ${IMAGE_TAG}'
                echo "Docker image push successfully"
            }
        }      
    }
}
