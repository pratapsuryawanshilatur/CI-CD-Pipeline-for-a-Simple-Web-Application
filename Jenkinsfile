pipeline {
    agent any
    environment {
        // Use your actual Docker Hub username here
        DOCKER_IMAGE = 'pratap2298/my-python-app'
        DOCKER_TAG = "${env.BUILD_ID}"
    }
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // For Windows, use bat with direct variable access
                    bat """
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}:latest .
                    """
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    bat """
                        docker run -d --name test-container -p 5000:5000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                        timeout /t 5 /nobreak > nul
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
                            echo ${DOCKER_PASSWORD} | docker login --username pratap2298 --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }
        stage('Cleanup Local') {
            steps {
                script {
                    bat """
                        docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest 2>nul || echo "Images already removed"
                    """
                }
            }
        }
    }
    post {
        success {
            echo "Pipeline succeeded! Image pushed to Docker Hub as ${DOCKER_IMAGE}:${DOCKER_TAG}"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}