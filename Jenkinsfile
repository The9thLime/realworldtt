pipeline {
    agent {
        kubernetes {
            label 'kubeagent'
            yaml """
            apiVersion: v1
            kind: Pod
            metadata:
              labels:
                some-label: kubeagent
            spec:
              containers:
              - name: python
                image: python:alpine
                command:
                - cat
            """
        }
    }

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub_id' // Replace with your Docker Hub credentials ID
        IMAGE_NAME = 'realworldtt'
        IMAGE_TAG = 'latest'
    }

    stages {

        stage('Setup Environment') {
            steps {
                container(python) {
                    sh 'python3 -m venv venv'
                    sh '. venv/bin/activate'
                    sh 'pip install -r requirements.txt'
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
