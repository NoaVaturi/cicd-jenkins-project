pipeline {
    agent any

    environment {
        IMAGE_NAME = 'vnoah/flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.GIT_COMMIT.take(7)}"
        DOCKER_CREDENTIALS = 'dockerhub-creds'
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
                bash -c "source app/env/bin/activate && pytest test_app.py"
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS) {
                        echo "Logged in to DockerHub"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_TAG}")
                }
                echo "Docker image built successfully."
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS) {
                        docker.image("${IMAGE_TAG}").push()
                    }
                }
                echo "Docker image pushed successfully to DockerHub."
            }
        }
    }

    post {
        cleanup {
            sh 'docker system prune -f'  // Optional: clean up unused Docker data
            echo "Cleaned up Docker environment."
        }
    }
}
