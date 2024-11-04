pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: python
            image: python:3.10
            command:
            - cat
            tty: true
          - name: kaniko
            image: gcr.io/kaniko-project/executor:debug
            command:
            - cat
            tty: true
            volumeMounts:
              - name: registry-credentials
                mountPath: /kaniko/.docker
          volumes:
            - name: registry-credentials
              secret:
                secretName: regcred
                items:
                - key: .dockerconfigjson
                  path: config.json'''
    }
  }
  stages {
    stage('Test') {
      steps {
        container('python') {
          sh 'pip install -r requirements.txt'
          sh 'python test_app.py'
        }
      }
    }
    stage('Docker Build') {
      steps {
        container('kaniko') {
          sh "executor --dockerfile=Dockerfile \
          --context=dir://${env.WORKSPACE} \
          --destination=<docker-id>/test-app:${currentBuild.number}"
        }
      }
    }
    stage('Modified deployment.yaml') {
      steps {
        sh "sed -i 's/test-app:.*\$/test-app:${currentBuild.number}/g' deployment.yaml"
        withCredentials([gitUsernamePassword(credentialsId: 'k8scicd',
          gitToolName: 'git-tool')]) {
            sh 'git checkout main'
            sh 'git fetch --all'
            sh 'git add deployment.yaml'
            sh "git commit -m 'Update image version test-app:${currentBuild.number} in deployment.yaml'"
            sh 'git push -u origin main'
          }
      }
      post {
        success {
          echo 'Deploy Success'
        }
        failure {
          echo 'Deploy Failure'
        }
      }
    }
  }
}
