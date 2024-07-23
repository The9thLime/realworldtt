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
            image: python:3.9
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
   stages {
    stage('Run test') {
      steps {
        container('python') {
          withEnv([
            'SECRET_KEY=django-insecure-f35(x7w#1hz7%oejc(t(x8ii7n^%n0pvzsp@x*qtfh8^$3^3j+',
            'DATABASE_NAME=realworld',
            'DATABASE_USER=realworld',
            'DATABASE_PASSWORD=123',
            'DATABASE_HOST=127.0.0.1',
            'DATABASE_PORT=3306'
          ]) {
            sh '''
              apt-get update && apt-get install -y \
              pkg-config \
              default-libmysqlclient-dev
              cd django/
              pip install -r ../requirements.txt
              python manage.py test
            '''
          }
        }
      }
    }
    stage('Build docker image') {
        steps {
            container('docker') {
                sh '''
                    docker build -t the9thlime/realworldtt:0.0.${BUILD_NUMBER} .
                '''
                script {
                    withDockerRegistry([credentialsId: "dockerhub", url: 'https://index.docker.io/v1/']) {
                        sh 'docker push the9thlime/realworldtt:0.0.${BUILD_NUMBER}'
                    }
                }
            }
        }
    }
    stage('Deploy YAML files') {
        steps {
            container('kubectl') {
                script {
                    sh '''
                        kubectl apply -f ./k8s/
                    '''
                }
            }
        }
    }
    stage('Update Kubernetes Manifest') {
        steps {
            container('kubectl') {
                script {
                    sh '''
                        kubectl get pods -n default
                        kubectl set image deployment/realworldtt-deployment realworldtt=the9thlime/realworldtt:0.0.${BUILD_NUMBER} -n default
                        kubectl rollout status deployment/realworldtt-deployment -n default
                    '''
                }
            }
        }
    }
  }
}
