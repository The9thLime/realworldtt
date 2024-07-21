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
                python manage.py test
            '''
        }
      }
    }
  }
}