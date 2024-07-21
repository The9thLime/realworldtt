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
            image: python:slim
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
          sh ''' 
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
                    docker ps
                '''
            }
        }
    }
  }
}