# CI/CD Pipeline for a Simple Python Web Application

## Project Overview
This project implements a complete CI/CD pipeline for a Flask web application using Jenkins, Docker, and GitHub Webhooks.

## Features
- **Automated CI/CD**: Pipeline triggers on every git push
- **Dockerized Application**: Multi-stage Docker build for optimized image size
- **Docker Hub Integration**: Automated image publishing
- **Health Checks**: Container health monitoring
- **Local Jenkins with Ngrok**: Cost-free pipeline setup

## Technologies Used
- **Version Control**: Git, GitHub
- **CI/CD Server**: Jenkins (Local setup)
- **Containerization**: Docker, Docker Hub
- **Web Framework**: Python Flask
- **Webhook Tunnel**: Ngrok

## Setup Instructions

### 1. Prerequisites
- Docker installed
- Jenkins installed locally
- Ngrok installed
- Docker Hub account
- GitHub account

### 2. Local Jenkins Setup
```bash
# Start Jenkins
sudo systemctl start jenkins

# Expose Jenkins via ngrok
ngrok http 8080

3. GitHub Webhook Configuration
Go to Repository Settings → Webhooks → Add webhook

Payload URL: https://[your-ngrok-url]/github-webhook/

Content type: application/json

Events: Just the push event

4. Jenkins Pipeline Configuration
Create new Pipeline job in Jenkins

Set Pipeline definition to "Pipeline script from SCM"

Configure Git repository URL

Set branch to */main

Script path: Jenkinsfile

5. Docker Hub Integration
Create Docker Hub credentials in Jenkins

Update Jenkinsfile with your Docker Hub username

Pipeline will automatically push images on successful builds

Pipeline Stages
Build: Creates Docker image with multi-stage build

Test: Runs container and tests HTTP response

Push: Publishes image to Docker Hub with build ID tag

Cleanup: Removes local images to save space

How to Run Locally
bash
# Clone repository
git clone https://github.com/yourusername/your-repo.git

# Build and run
docker build -t my-app .
docker run -p 5000:5000 my-app

# Access application
curl http://localhost:5000
Project Status
✅ CI/CD Pipeline Working
✅ Docker Optimization Complete
✅ Docker Hub Integration
✅ GitHub Webhooks Configured