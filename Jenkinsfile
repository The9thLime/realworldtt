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
          - name: mysql
            image: mysql:latest
            tty: true
            env:
            - name: MYSQL_ROOT_PASSWORD
              value: '123'
            - name: MYSQL_DATABASE
              value: 'test_db'
            
            ports:
            - containerPort: 3306
              name: mysql

          volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock   
        '''
      retries 2
    }
  }
  stages {
    stage('Wait for MySQL') {
            steps {
                container('mysql') {
                    sh '''
                        echo "Waiting for MySQL to be ready..."
                        while ! mysqladmin ping -h"127.0.0.1" --silent; do
                            sleep 1
                        done
                        echo "MySQL is up and running!"
                    '''
                }
            }
        }
    stage('Run test') {
      steps {
        container('python') {
          sh ''' 
                echo $DATABASE_NAME
                cd django/
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