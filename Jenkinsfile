pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = credentials('AWS_ACCOUNT_ID')
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY = 'ecommerce-api'
        ECR_REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
        KUBECONFIG = credentials('eks-kubeconfig')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                dir('backend') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }
        
        stage('Test') {
            steps {
                dir('backend') {
                    sh 'mvn test'
                }
            }
        }
        
        stage('Build and Push Docker Image') {
            steps {
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                sh "docker build -t ${ECR_REPOSITORY_URI}:${env.BUILD_NUMBER} -t ${ECR_REPOSITORY_URI}:latest ."
                sh "docker push ${ECR_REPOSITORY_URI}:${env.BUILD_NUMBER}"
                sh "docker push ${ECR_REPOSITORY_URI}:latest"
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                sh "sed -i 's|\${ECR_REPOSITORY_URI}|${ECR_REPOSITORY_URI}|g' kubernetes/deployment.yaml"
                sh "kubectl --kubeconfig=${KUBECONFIG} apply -f kubernetes/deployment.yaml"
                sh "kubectl --kubeconfig=${KUBECONFIG} apply -f kubernetes/service.yaml"
                sh "kubectl --kubeconfig=${KUBECONFIG} apply -f kubernetes/ingress.yaml"
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}