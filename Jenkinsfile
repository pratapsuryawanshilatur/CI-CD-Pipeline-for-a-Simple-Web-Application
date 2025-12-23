pipeline {
    agent any
    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-python-app .'
            }
        }
        stage('Test') {
            steps {
                // A simple test: does the container start?
                sh '''
                docker run -d --name test-container -p 5000:5000 my-python-app
                sleep 5
                curl -f http://localhost:5000 || exit 1
                '''
            }
            post {
                always {
                    sh 'docker stop test-container || true'
                    sh 'docker rm test-container || true'
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