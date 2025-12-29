pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'pratap2298/my-python-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}-waitress"  // Use build number
    }
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    bat 'docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    bat """
                        docker run -d --name test-container -p 5000:5000 %DOCKER_IMAGE%:%DOCKER_TAG%
                        ping -n 30 127.0.0.1 > nul
                        curl -f http://localhost:5000 || exit 1
                    """
                }
            }
            post {
                always {
                    script {
                        bat """
                            docker stop test-container 2>nul || echo "Container already stopped"
                            docker rm test-container 2>nul || echo "Container already removed"
                        """
                    }
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'DOCKER_HUB_CREDENTIALS', variable: 'DOCKER_PASSWORD')]) {
                        bat """
                            echo %DOCKER_PASSWORD% | docker login --username pratap2298 --password-stdin
                            docker push %DOCKER_IMAGE%:%DOCKER_TAG%
                        """
                    }
                }
            }
        }
        stage('Deploy to Kubernetes (EKS Fargate)') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'aws-eks-credentials',
                            usernameVariable: 'AWS_ACCESS_KEY_ID',
                            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                        )
                    ]) {
                        // Update deployment.yaml with new image tag
                        bat """
                            
                            kubectl set image deployment/python-webapp-fargate python-webapp=%DOCKER_IMAGE%:%DOCKER_TAG% --record
                            
                            
                            
                        """
                        
                        bat """
                            ping -n 30 127.0.0.1 > nul
                            kubectl rollout status deployment/python-webapp-fargate --timeout=120s
                        """
                        
                        bat """
                            echo "Getting Load Balancer URL..."
                            kubectl get service python-webapp-service -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
                            echo ""
                            echo "Deployment updated with image: %DOCKER_IMAGE%:%DOCKER_TAG%"
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                bat """
                    docker rmi %DOCKER_IMAGE%:%DOCKER_TAG% 2>nul || echo "Image already removed"
                """
            }
        }
        success {
            echo "✓ Pipeline succeeded!"
            echo "✓ Docker Image: %DOCKER_IMAGE%:%DOCKER_TAG%"
            echo "✓ Deployed to EKS Fargate cluster"
        }
    }
}