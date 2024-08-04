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
  - name: build
    image: the9thlime/sedgit:latest
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
        container('build') {
          sh ''' 
                echo $DATABASE_NAME
                python3 -m venv venv
                source venv/bin/activate
                pip install -r requirements.txt
                cd django/
                python manage.py test
            '''
        }
      }
    }

    stage('Build docker image') {
        steps {
            container('build') {
                script {
                    withDockerRegistry([credentialsId: "dockerhub", url: 'https://index.docker.io/v1/']) {
                        sh 'docker build -t the9thlime/realworldtt:0.0.${BUILD_NUMBER} .'
                        sh 'docker push the9thlime/realworldtt:0.0.${BUILD_NUMBER}'
                        sh 'docker tag the9thlime/realworldtt:0.0.${BUILD_NUMBER} the9thlime/realworldtt:latest'
                        sh 'docker push the9thlime/realworldtt:latest'
                    }
                }
            }
        }
    }

     stage('Update Kubernetes Manifest') {
            steps { 
              withCredentials([sshUserPrivateKey(credentialsId: 'github', keyFileVariable: 'KEY')]){
                container('build') {
                    script {
                        sh """
                            eval `ssh-agent -s`
                            trap "ssh-agent -k" EXIT
                            ssh-add "$KEY"
                            git config --global user.email "ayushj0909@outlook.com"
                            git config --global user.name "Ayush Jain"
                            mkdir -p ~/.ssh
                            echo "Host github.com\n\tStrictHostKeyChecking no\n" > ~/.ssh/config
                            git clone git@github.com:The9thLime/realworldtt.git realworld
                            cd realworld
                            touch testfile
                            git add testfile && git commit -m "automation" && git push 
                        """
                        }
                  }
              }
            }
    }
  }
}