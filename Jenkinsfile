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
                - sleep
                args:
                - 99d
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
                    sh 'echo BATMAN'
                }
            }
        }

        
    }
}
