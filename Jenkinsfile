pipeline {
    agent {
        node {
            label 'master'
        }
    }
  environment {
        WORK_DIR = 'workspace/Project-Utopia/build'
        TERRAFORM_CMD = 'docker run --network host -w /app -v /tmp/${WORK_DIR}:/app hashicorp/terraform:light'
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
                    ${TERRAFORM_CMD} init -backend=true -backend-config="bucket=${TF_BACKEND_S3_BUCKET}" -backend-config="key=${TF_BACKEND_S3_KEY}" -backend-config="region=${AWS_DEFAULT_REGION}" -input=false
                    """
                }
            }
        }

    stage('plan') {
            steps {
                withAWS(credentials:'8f8055f0-fef5-47b6-915b-d34669729c37') {
                sh  """
                    ${TERRAFORM_CMD} plan -var "aws['aws_access_key']=${AWS_ACCESS_KEY_ID}" -var "aws['aws_secret_key']=${AWS_SECRET_ACCESS_KEY}" -var "aws['account']=${AWS_ACCOUNT_NUM}" -var "key_pair=${AWS_PEM_KEY}" -out=${WORK_DIR}tfoutput.plan -input=false
                    """
                }
            }
        }
  }
}