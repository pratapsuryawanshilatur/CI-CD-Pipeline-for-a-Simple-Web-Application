'''
pipeline {
    agent any
    stages {
        stage('Build Docker Image') {
            steps {
                bat 'docker build -t my-python-app .'
            }
        }
        stage('Test') {
            steps {
                // A simple test: does the container start?
                bat '''
                docker run -d --name test-container -p 5000:5000 my-python-app
                sleep 5
                curl -f http://localhost:5000 || exit 1
                '''
            }
            post {
                always {
                    bat 'docker stop test-container || true'
                    bat 'docker rm test-container || true'
                }
            }
        
        }
        stage('Deploy') {
            steps {
                echo 'Deploying container...'
                //For now, just echo. We'll add real deployment in phase 4.
            }
        }  
    }
}
'''

pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'pratap2298/my-python-app'
        DOCKER_TAG = '${env.BUILD_ID}'
    }
    stages {
        stage('Build Docker Image') {
            steps {
                bat 'docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}: latest .'
            }
        }
        stage ('Test') {
            steps {
                bat '''
                docker run -d --name test-container -p 5000:5000 ${DOCKER_IAMGE}:${DOCKER_TAG}
                sleep 5
                curl -f http://localhost:5000 || exit 1
                '''
            }
            post {
                always {
                    bat 'docker stop test-container || true'
                    bat 'docker rm test-container || true'
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([string(credentialsId: 'Docker_HUB_CREDENTIALS', variable: 'DOCKER_PASSWORD')]) {
                    bat '''
                    echo "${DOCKER_PASSWORD}" | docker login --username pratap2298 --password-stdin
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }
        stage('Cleanup Local') {
            steps {
                bat 'docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest || true'
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