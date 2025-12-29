pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'pratap2298/my-python-app'
    }
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    bat 'docker build -t %DOCKER_IMAGE%:waitress .'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    bat """
                        docker run -d --name test-container -p 5000:5000 %DOCKER_IMAGE%:waitress
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
                            docker push %DOCKER_IMAGE%:waitress
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
                        bat """
                            aws configure set aws_access_key_id %AWS_ACCESS_KEY_ID%
                            aws configure set aws_secret_access_key %AWS_SECRET_ACCESS_KEY%
                            aws configure set region eu-west-2
                            aws configure set output json
                        """
                        
                        bat """
                            aws eks update-kubeconfig --name my-fargate-cluster --region eu-west-2
                        """
                        
                        bat """
                            kubectl apply -f fargate-deployment.yaml
                            kubectl apply -f fargate-service.yaml
                        """
                        
                        bat """
                            ping -n 30 127.0.0.1 > nul
                            kubectl rollout status deployment/python-webapp-fargate --timeout=120s
                        """
                        
                        bat """
                            echo "Getting Load Balancer URL..."
                            kubectl get service python-webapp-service -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
                            echo ""
                        """
                    }
                }
            }
        }
        stage('Cleanup Local') {
            steps {
                script {
                    bat """
                        docker rmi %DOCKER_IMAGE%:waitress 2>nul || echo "Image already removed"
                    """
                }
            }
        }
    }
    
    // POST section should be at the end, outside stages
    post {
        success {
            script {
                echo "Pipeline succeeded! Image pushed to Docker Hub as %DOCKER_IMAGE%:waitress"
                echo "Application deployed to EKS Fargate"
                echo "Load Balancer URL: Check kubectl get service output above"
            }
        }
        failure {
            script {
                echo "Pipeline failed!"
            }
        }
        always {
            script {
                echo "Pipeline completed"
                // Optional: Add cleanup or notifications here
            }
        }
    }
}