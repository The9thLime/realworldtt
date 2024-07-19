pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub_id' // Replace with your Docker Hub credentials ID
        IMAGE_NAME = 'realworldtt'
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/The9thLime/realworldtt.git']]])
            }
            }
        }

        stage('Setup Environment') {
            steps {
                script {
                    sh 'python3 -m venv venv'
                    sh '. venv/bin/activate'
                    sh 'pip install -r requirements.txt'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh '. venv/bin/activate'
                    sh 'pytest'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                // Build Docker image for your Django app
                script {
                    sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                // Push Docker image to Docker Hub
                script {
                    withDockerRegistry([credentialsId: "${DOCKER_CREDENTIALS_ID}", url: 'https://index.docker.io/v1/']) {
                        sh 'docker push ${IMAGE_NAME}:${IMAGE_TAG}'
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                // Deploy Docker image to Minikube Kubernetes cluster
                script {
                    sh 'kubectl apply -f k8s/main-deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                }
            }
        }
    }

    post {
        always {
            // Clean up workspace or perform other post-build actions
            cleanWs()
        }
    }
}
