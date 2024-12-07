pipeline {
    agent any

    environment {
        IMAGE_NAME = 'vnoah/flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.GIT_COMMIT.take(7)}"
        KUBECONFIG = '/tmp/kubeconfig'
    }

    stages {
        stage('Setup') {
            steps {
                sh 'chmod +x steps.sh'
                sh './steps.sh'
                

                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG')]) {
                    sh 'chmod 644 ${KUBECONFIG}'
                    sh 'aws sts get-caller-identity'
                    sh 'kubectl config get-contexts --kubeconfig=${KUBECONFIG}'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'bash -c "source app/env/bin/activate && pytest test_app.py"'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', 
                                             usernameVariable: 'DOCKER_USER', 
                                             passwordVariable: 'DOCKER_PASSWORD')]) {
                           
                    script {
                        def image = docker.build("${DOCKER_USER}/flask-app:${IMAGE_TAG}")
                        image.push()
                    }
                }   
            }
        }

        stage('Deploy to Staging') {
            steps {
                sh 'kubectl config use-context stage --kubeconfig=${KUBECONFIG}'

                sh '''
                helm upgrade --install flask-app ./helm \
                     --namespace stage-namespace \
                     --set namespace=stage-namespace \
                     --set image.tag="${IMAGE_TAG}"
                '''
            }
        }

        stage('Acceptance Test') {
            steps {
                script {
                    sh 'sleep 30'

                    def service = ''
                    def retryCount = 0

                    while (!service && retryCount < 5) {
                        try {
                            service = sh(script: "kubectl get svc flask-app-service --namespace=stage-namespace -o jsonpath='{.status.loadBalancer.ingress[0].hostname}:{.spec.ports[0].port}' --kubeconfig=${KUBECONFIG}", returnStdout: true).trim()
                        } catch (Exception e) {
                            retryCount++
                            echo "Retry ${retryCount}: Waiting for service to be available..."
                            sh 'sleep 30'
                        }
                    }

                    if (!service) {
                        error "Service not found after 5 retries. Acceptance test failed."
                    }

                    echo "Running acceptance tests on service: ${service}"

                    sh """
                    docker run --rm -v \$(pwd):/scripts grafana/k6 run -e SERVICE=${service} /scripts/acceptance-test.js
                    """
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                sh 'kubectl config use-context prod --kubeconfig=${KUBECONFIG}'

                sh '''
                helm upgrade --install flask-app ./helm \
                     --namespace prod-namespace \
                     --set namespace=prod-namespace \
                     --set image.tag="${IMAGE_TAG}"
                '''
            }
        }       
    }

    post {
        cleanup {
            sh 'docker system prune -f'
            sh 'rm -rf ~/.kube/cache || true'
        }
    }

}
