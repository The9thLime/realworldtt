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
            - name: MYSQL_USER
              value: 'realworld'
            - name: MYSQL_PASSWORD
              value: '123'
            
            ports:
            - containerPort: 3306
              name: mysql

          volumes:
          - name: mysqld-sock
            hostPath: /var/run/mysqld/mysqld.sock
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock   
        '''
      retries 2
    }
  }
  environment{
    DATABASE_NAME = 'realworld'
    DATABASE_USER = 'realworld'
    DATABASE_HOST = 'localhost'
    DATABASE_PORT = '3306'
    DATABASE_PASSWORD = '123'
    SECRET_KEY = 'django-insecure-f35(x7w#1hz7%oejc(t(x8ii7n^%n0pvzsp@x*qtfh8^$3^3j+'
  }
  stages {
    stage('Wait for MySQL') {
            steps {
                container('mysql') {
                    sh '''
                        echo "Waiting for MySQL to be ready..."
                        while ! mysqladmin ping --password=123 --silent; do
                            sleep 1
                        done
                    '''
                }
            }
        }
    stage('Run test') {
      steps {
        container('python') {
          sh ''' 
                export DATABASE_NAME=${DATABASE_NAME}
                export DATABASE_USER=${DATABASE_USER}
                export DATABASE_PASSWORD=${DATABASE_PASSWORD}
                export DATABASE_HOST=${DATABASE_HOST}
                export DATABASE_PORT=${DATABASE_PORT}
                export SECRET_KEY=${SECRET_KEY}
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