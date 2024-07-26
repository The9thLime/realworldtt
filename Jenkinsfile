pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            some-label: some-label-value
        spec:
          containers:
          - name: python
            image: the9thlime/realworldtt:test
            command:
            - cat
            tty: true
          - name: kubectl
            image: alpine/k8s:1.30.3
            command:
            - cat
            tty: true
          - name: docker
            image: docker:latest
            command:
            - cat
            tty: true
            volumeMounts:
             - mountPath: /var/run/docker.sock
               name: docker-sock
          volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock   
        '''
      retries 2
    }
  }
  environment {
        // Fetch secret values from Kubernetes
        DATABASE_NAME = sh(script: "kubectl get secret django_secrets -o jsonpath='{.data.DATABASE_NAME}' | base64 --decode", returnStdout: true).trim()
        DATABASE_USER = sh(script: "kubectl get secret django_secrets -o jsonpath='{.data.DATABASE_USER}' | base64 --decode", returnStdout: true).trim()
        DATABASE_PASSWORD = sh(script: "kubectl get secret django_secrets -o jsonpath='{.data.DATABASE_PASSWORD}' | base64 --decode", returnStdout: true).trim()
        DATABASE_HOST = sh(script: "kubectl get secret django_secrets -o jsonpath='{.data.DATABASE_HOST}' | base64 --decode", returnStdout: true).trim()
        DATABASE_PORT = sh(script: "kubectl get secret django_secrets -o jsonpath='{.data.DATABASE_PORT}' | base64 --decode", returnStdout: true).trim()
        SECRET_KEY = sh(script: "kubectl get secret django_secrets -o jsonpath='{.data.SECRET_KEY}' | base64 --decode", returnStdout: true).trim()
    }
  stages {
    stage('Run test') {
      steps {
        container('python') {
          sh ''' 
                export DATABASE_NAME=${DATABASE_NAME}
                export DATABASE_USER=${DATABASE_USER}
                export DATABASE_PASSWORD=${DATABASE_PASSWORD}
                export DATABASE_HOST=${DATABASE_HOST}
                export DATABASE_PORT=${DATABASE_PORT}
                export DATABASE_NAME=${SECRET_KEY}
                echo $DATABASE_NAME
                cd django/
                pip install -r ../requirements.txt
                python manage.py test
            '''
        }
      }
    }
    stage('Build docker image') {
        steps {
            container('docker') {
                sh '''
                    docker build -t the9thlime/realworldtt:0.0.${BUILD_NUMBER}.dev .
                '''
                script {
                    withDockerRegistry([credentialsId: "dockerhub", url: 'https://index.docker.io/v1/']) {
                        sh 'docker push the9thlime/realworldtt:0.0.${BUILD_NUMBER}.dev'
                    }
                }
            }
        }
    }
     stage('Update Kubernetes Manifest') {
            steps {
                container('kubectl') {
                    script {
                        sh """
                            kubectl get pods -n default
                            kubectl set image deployment/realworldtt-deployment realworldtt=the9thlime/realworldtt:0.0.${BUILD_NUMBER} -n default
                            kubectl rollout status deployment/realworldtt-deployment -n default
                        """
                    }
                }
            }
        }
    }
}