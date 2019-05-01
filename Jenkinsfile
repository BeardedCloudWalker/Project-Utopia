pipeline {
    agent {
        node {
            label 'master'
        }
    }
  environment {
        TERRAFORM_CMD = 'docker run --network host -w /app -v ${HOME}/.aws:/root/.aws -v ${HOME}/.ssh:/root/.ssh -v /tmp/workspace/Project-Utopia:/app hashicorp/terraform:light'
    }
  stages {
      stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('test ls') {
            steps {
                sh  'ls -l'
            }
        }
    stage('pull latest light terraform image') {
            steps {
                sh  """
                    docker pull hashicorp/terraform:light
                    """
            }
        }
    stage('init') {
            steps {
                sh  'pwd'
                sh  """
                    ${TERRAFORM_CMD} init -backend=false -input=false
                    """
            }
        }
  }
}