pipeline {
    agent any

    environment {
        IMAGE_NAME = 'vnoah/flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.GIT_COMMIT.take(7)}"
        DOCKER_CREDENTIALS = 'dockerhub-creds'
        KUBECONFIG = credentials('kubeconfig-creds')
        AWS_CREDENTIALS = credentials('aws-creds')
    }

    stages {
        stage('Setup') {
            steps {
                sh 'bash steps.sh'
                sh 'kubectl config get-contexts'
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
                        echo "Logged in to DockerHub."
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

        stage('Deploy to Staging') {
            steps {
                sh 'chmod 600 $KUBECONFIG'
                sh 'export KUBECONFIG=$KUBECONFIG'
                sh 'kubectl config use-context staging-cluster'
                sh 'kubectl config current-context'
                sh "kubectl set image deployment/flask-app flask-app=${IMAGE_TAG}"
            }
        }

        stage('Acceptance Test') {
            steps {
                script {
                    def service = sh(script: "kubectl get svc flask-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}:{.spec.ports[0].port}'", returnStdout: true).trim()
                    echo "${service}"

                    sh "k6 run -e SERVICE=${service} acceptance-test.js"
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                sh 'kubectl config use-context production-cluster'
                sh 'kubectl config current-context'
                sh "kubectl set image deployment/flask-app flask-app=${IMAGE_TAG}"
                //withCredentials([file(credentialsId: 'kubeconfig-credentials', variable: 'KUBECONFIG')]) {
                    
                //}
            }
        }       
    }

    post {
        cleanup {
            sh 'docker system prune -f'  // Optional: Clean up unused Docker data
            echo "Cleaned up Docker environment."
        }
    }

}
