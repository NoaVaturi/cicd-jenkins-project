pipeline {
    agent any

    environment {
        IMAGE_NAME = 'vnoah/flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.GIT_COMMIT.take(7)}"
        DOCKER_CREDENTIALS = 'dockerhub-creds'
        KUBECONFIG = '/tmp/kubeconfig'
    }

    stages {
        stage('Setup') {
            steps {
                sh 'bash steps.sh'
                sh 'chmod +x steps.sh'
                sh 'aws sts get-caller-identity'

                sh '''
                aws eks --region us-east-1 update-kubeconfig --name staging-cluster --alias staging-context --kubeconfig=${KUBECONFIG}
                aws eks --region us-east-1 update-kubeconfig --name production-cluster --alias production-context --kubeconfig=${KUBECONFIG}
                '''
               sh 'kubectl config get-contexts --kubeconfig=${KUBECONFIG}'
            }
        }

        stage('Test') {
            steps {
                sh 'bash -c "source app/env/bin/activate && pytest test_app.py"'
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
                    // Use docker.withRegistry for secure login and image push
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
                sh 'kubectl apply -f deployment.yml --namespace=staging-namespace --kubeconfig=${KUBECONFIG}'
                sh 'kubectl apply -f service.yml --namespace=staging-namespace --kubeconfig=${KUBECONFIG}'
                sh "kubectl set image deployment/flask-app flask-app=${IMAGE_TAG} --namespace=staging-namespace --kubeconfig=${KUBECONFIG}"
            }
        }

        stage('Acceptance Test') {
            steps {
                script {
                    // Wait for 30 seconds to allow time for the service to be available
                    sh 'sleep 30'

                    // Initialize a variable to hold the service information
                    def service = ''
                    def retryCount = 0

                    // Retry getting the service until it's available or we reach the maximum retry count
                    while (!service && retryCount < 5) {
                                service = sh(script: "kubectl get svc flask-app-service --namespace=staging-namespace -o jsonpath='{.status.loadBalancer.ingress[0].hostname}:{.spec.ports[0].port}' --kubeconfig=${KUBECONFIG}", returnStdout: true).trim()
                
                                if (!service) {
                                        retryCount++
                                        echo "Retry ${retryCount}: Service not found, waiting 30 more seconds."
                                        sh 'sleep 30'
                                }
                    }    

                    // If the service is still not found after retries, fail the build
                    if (!service) {
                            error "Service not found after 5 retries. Failing the acceptance test."
                    }

                    echo "Running acceptance tests on service: ${service}"

                     // Run the k6 test using the Docker container
                    sh """
                    docker run --rm -v \$(pwd):/scripts grafana/k6 run -e SERVICE=${service} /scripts/acceptance-test.js
                    """
                }
            }
        }




        stage('Deploy to Production') {
            steps {
                sh 'kubectl config use-context production-context --kubeconfig=${KUBECONFIG}'
                sh 'kubectl apply -f deployment.yml --namespace=production-namespace --kubeconfig=${KUBECONFIG}'
                sh 'kubectl apply -f service.yml --namespace=production-namespace --kubeconfig=${KUBECONFIG}'
                sh "kubectl set image deployment/flask-app flask-app=${IMAGE_TAG} --namespace=production-namespace --kubeconfig=${KUBECONFIG}"
            }
        }       
    }
    
    post {
        cleanup {
            sh 'docker system prune -f'  // Optional: Clean up unused Docker data
            sh 'if [ -d ~/.kube/cache ]; then rm -rf ~/.kube/cache; fi' // Only remove cache if it exists
            echo "Cleaned up Docker environment and removed kubeconfig file."
        }
    }

}
