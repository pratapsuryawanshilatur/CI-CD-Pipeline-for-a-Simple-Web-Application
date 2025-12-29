pipeline {
    agent any
    environment {
        // Use your actual Docker Hub username here
        DOCKER_IMAGE = 'pratap2298/my-python-app'
        //DOCKER_TAG = "${env.BUILD_ID}"
    }
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // For Windows, use bat with direct variable access
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
                    // First, create the credentials in Jenkins if you haven't
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
                    withCredentials([usernamePassword(
                        credentialsId: 'aws-eks-credentials',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )]){
                        // Configure AWS CLI
                        bat """
                            aws configure set aws_access_key_id %AWS_ACCESS_KEY_ID%
                            aws configure set aws_secret_access_key %AWS_SECRET_ACCESS_KEY%

                            aws configure set region eu-west-2
                            aws configure set output json
                        """

                        // Connect to EKS cluster
                        bat """
                            aws eks update-kubeconfig --name my-fargate-cluster --region eu-west-2
                        """
                        // Deploy to Kubernetes

                        bat """
                            kubectl apply -f fargate-deployment.yaml
                            kubectl apply -f fargate-service.yaml
                        """

                        // Wait for deployment
                        bat """
                            ping -n 30 127.0.0.1 > nul
                            kubectl rollout status deployment/python-webapp-fargate --timeout=120s
                        """
                        // Get NLB URL
                        bat """
                            echo "Getting Load Balancer URL..."
                            kubectl get service python-webapp-service -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
                            echo ""
                        """
                    }
                }
            }

        }
        stage('Deploy to AWS with Ansible') {
            steps {
                script {
                    // This runs the playbook from the WSL environment
                    bat 'wsl ansible-playbook -i inventory.ini deploy-playbook.yml'
                }
            }

        }
        stage('Cleanup Local') {
            steps {
                script {
                    bat """
                        docker rmi %DOCKER_IMAGE%:waitress %DOCKER_IMAGE%:waitress 2>nul || echo "Images already removed"
                    """
                }
            }
        }
    }
    post {
        success {
            echo "Pipeline succeeded! Image pushed to Docker Hub as %DOCKER_IMAGE%:waitress"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}