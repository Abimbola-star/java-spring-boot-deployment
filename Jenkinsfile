pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'ecommerce'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        KUBECONFIG = credentials('eks-kubeconfig')
        AWS_CREDENTIALS = credentials('aws-credentials')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/Abimbola-star/java-spring-boot-deployment.git'
            }
        }
        
        
        stage('Build and Push Docker Image') {
            steps {
                sh '''
                export AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}
                export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                cd backend && docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} .
                docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                '''
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                sh '''
                export AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}
                export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
                sed -i "s|image: .*|image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}|g" k8s-deployment.yaml
                export KUBECONFIG=${KUBECONFIG}
                kubectl apply -f k8s-deployment.yaml
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}