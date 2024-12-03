pipeline {
    agent any

    environment {
        IMAGE_NAME = 'vnoah/flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.GIT_COMMIT.take(7)}"
        DOCKER_CREDENTIALS = 'dockerhub-creds'
        KUBECONFIG = '/tmp/kubeconfig'
        AWS_CREDENTIALS = credentials('aws-creds')
    }

    stages {
        stage('Setup') {
            steps {
                sh 'bash steps.sh'
                sh '''
                aws sts get-caller-identity
                '''

                sh 'aws eks --region us-east-1 update-kubeconfig --name staging-cluster --alias staging-context --kubeconfig /tmp/kubeconfig'
                sh 'aws eks --region us-east-1 update-kubeconfig --name production-cluster --alias production-context --kubeconfig /tmp/kubeconfig'
                sh 'chmod 600 /tmp/kubeconfig'
                sh 'cat /tmp/kubeconfig'
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
                    // Using docker.withRegistry to securely login to DockerHub
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS) {
                        docker.image("${IMAGE_TAG}").push()
                    }
                }
                echo "Docker image pushed successfully to DockerHub."
            }
        }

        stage('Deploy to Staging') {
            steps {
                sh 'kubectl config use-context staging-context --kubeconfig=${KUBECONFIG}'
                sh "kubectl set image deployment/flask-app flask-app=${IMAGE_TAG} --kubeconfig=${KUBECONFIG}"
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
                sh 'kubectl config use-context production-context --kubeconfig=${KUBECONFIG}'
                sh "kubectl set image deployment/flask-app flask-app=${IMAGE_TAG} --kubeconfig=${KUBECONFIG}"
            }
        }       
    }

    post {
        cleanup {
            sh 'docker system prune -f'  // Optional: Clean up unused Docker data
            sh 'rm -f /tmp/kubeconfig'   // Remove the kubeconfig file
            echo "Cleaned up Docker environment and removed kubeconfig file."
        }
    }

}
