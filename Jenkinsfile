pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'ecommerce'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        KUBECONFIG = credentials('eks-kubeconfig')
        AWS_CREDENTIALS = credentials('aws-credentials')
        EKS_CLUSTER_NAME = 'eks-javaecomm-cluster'
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
        
        stage('Install AWS IAM Authenticator') {
            steps {
                sh '''
                # Detect architecture
                ARCH=$(uname -m)
                if [ "$ARCH" = "x86_64" ]; then
                    AUTH_ARCH="amd64"
                elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
                    AUTH_ARCH="arm64"
                else
                    echo "Unsupported architecture: $ARCH"
                    exit 1
                fi
                
                # Install AWS IAM Authenticator
                curl -Lo aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/${AUTH_ARCH}/aws-iam-authenticator
                chmod +x ./aws-iam-authenticator
                mkdir -p $HOME/bin
                mv ./aws-iam-authenticator $HOME/bin/
                
                # Verify installations
                kubectl version --client
                $HOME/bin/aws-iam-authenticator version
                '''
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                sh '''
                export AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}
                export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
                export PATH=$HOME/bin:$PATH
                
                # Generate kubeconfig using AWS CLI
                mkdir -p $HOME/.kube
                aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME} --kubeconfig $HOME/.kube/config
                
                # Verify the kubeconfig
                cat $HOME/.kube/config
                
                export KUBECONFIG=$HOME/.kube/config
                
                # Update the deployment file with the new image
                sed -i "s|image: .*|image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}|g" k8s-deployment.yaml
                
                # Apply the deployment
                kubectl apply -f k8s-deployment.yaml --validate=false
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