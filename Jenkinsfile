pipeline {
    agent {
        node {
            label 'master'
        }
    }
  environment {
        TERRAFORM_CMD = 'docker run --network host -w /app -v /tmp/workspace/Project-Utopia:/app hashicorp/terraform:light'
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
                withAWS(credentials:'8f8055f0-fef5-47b6-915b-d34669729c37') {
                sh  """
                    ${TERRAFORM_CMD} init -backend=false -input=false
                    """
                }
            }
        }

    stage('plan') {
            steps {
                withAWS(credentials:'8f8055f0-fef5-47b6-915b-d34669729c37') {
                sh  """
                    ${TERRAFORM_CMD} plan -out=tfoutput.tf -input=false
                    """
                }
            }
        }
  }
}