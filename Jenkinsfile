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
                sh  'echo $AWS_ACCESS_KEY_ID'
                sh  """
                    docker pull hashicorp/terraform:light
                    """
            }
        }
    stage('init') {
            
                withAWS(credentials:'8f8055f0-fef5-47b6-915b-d34669729c37') {
                sh  'echo $AWS_ACCESS_KEY_ID'
                sh  """
                    ${TERRAFORM_CMD} init -backend=false -input=false
                    """
                
            }
        }
  }
}