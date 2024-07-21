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
          - name: kubectl
            image: bitnami/kubectl:latest
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
    KUBECONFIG = '/var/run/secrets/kubernetes.io/serviceaccount/token'
  }
  stages {
    // stage('Run test') {
    //   steps {
    //     container('python') {
    //       sh ''' 
    //             cd django/
    //             pip install -r ../requirements.txt
    //             python manage.py test
    //         '''
    //     }
    //   }
    // }
    // stage('Build docker image') {
    //     steps {
    //         container('docker') {
    //             sh '''
    //                 docker build -t the9thlime/realworldtt:0.0.${BUILD_NUMBER} .
    //             '''
    //             script {
    //                 withDockerRegistry([credentialsId: "dockerhub", url: 'https://index.docker.io/v1/']) {
    //                     sh 'docker push the9thlime/realworldtt:0.0.${BUILD_NUMBER}'
    //                 }
    //             }
    //         }
    //     }
    // }
     stage('Update Kubernetes Manifest') {
            steps {
                container('kubectl') {
                    script {
                        sh """
                            kubectl set image deployment/realworldtt-deployment=the9thlime/realworldtt:0.0.7
                            kubectl rollout status deployment/realworldtt-deployment
                        """
                    }
                }
            }
        }
    }
}