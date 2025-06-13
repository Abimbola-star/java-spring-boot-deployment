pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = credentials('aws-account-id')  
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'ecommerce'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        EKS_CLUSTER_NAME = 'eks-javaecomm-cluster'
        AWS_ACCESS_KEY_ID = credentials('aws-credentials').username  
        AWS_SECRET_ACCESS_KEY = credentials('aws-credentials').password
        KUBECONFIG_PATH = '/var/lib/jenkins/.kube/config'  // Jenkins user's kubeconfig path on Jenkins EC2
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
                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                cd backend
                docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} .
                docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                '''
            }
        }
        
        
        stage('Deploy to EKS') {
            steps {
                sh '''
                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                export AWS_REGION=${AWS_REGION}
                export KUBECONFIG=${KUBECONFIG_PATH}
                
                # Update deployment image
                sed -i "s|image: .*|image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}|g" k8s-deployment.yaml
                
                # Use kubectl with kubeconfig that uses AWS IAM authenticator and credentials
                kubectl get nodes  # just to verify connectivity
                
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
