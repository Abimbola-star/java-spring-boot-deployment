<<<<<<< HEAD
# Java-spring-boot-deployment
=======
# Java E-Commerce Backend Project

This project implements a simple Java (Spring Boot) REST API with containerization, Kubernetes deployment, and monitoring.

## Components

1. **Spring Boot Application**: A simple REST API for e-commerce
2. **Docker**: Containerization of the application
3. **Terraform**: Infrastructure as Code for AWS EKS provisioning
4. **Kubernetes**: Deployment manifests for the application
5. **ALB Ingress Controller**: For exposing the application
6. **Jenkins**: CI/CD pipeline for automated build and deployment
7. **Prometheus & Grafana**: Monitoring solution

## Project Structure

```
project1_ecommerce_java/
├── backend/                  # Java Spring Boot application
├── kubernetes/               # Kubernetes manifests
├── terraform/                # Terraform IaC for EKS
├── Dockerfile                # Docker configuration
├── Jenkinsfile               # CI/CD pipeline
└── README.md                 # Project documentation
```

## Deployment Steps

### 1. Build and Run Locally

```bash
cd backend
mvn clean package
java -jar target/ecommerce-1.0-SNAPSHOT.jar
```

### 2. Build Docker Image

```bash
docker build -t ecommerce-api:latest .
docker run -p 8080:8080 ecommerce-api:latest
```

### 3. Provision EKS with Terraform

```bash
cd terraform
terraform init
terraform apply
```

### 4. Deploy to Kubernetes

```bash
# Configure kubectl to use the EKS cluster
aws eks update-kubeconfig --name ecommerce-eks --region us-west-2

# Create monitoring namespace
kubectl apply -f kubernetes/monitoring-namespace.yaml

# Deploy the application
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml

# Deploy monitoring
kubectl apply -f kubernetes/prometheus-config.yaml
kubectl apply -f kubernetes/prometheus-deployment.yaml
kubectl apply -f kubernetes/prometheus-service.yaml
kubectl apply -f kubernetes/grafana-deployment.yaml
kubectl apply -f kubernetes/grafana-service.yaml
```

### 5. Set up Jenkins Pipeline

1. Install Jenkins and required plugins
2. Create credentials for AWS and Kubernetes
3. Create a new pipeline job using the Jenkinsfile

## Accessing the Application

Once deployed, the application will be accessible through the ALB endpoint.

## Monitoring

- Prometheus: Access via `http://<prometheus-service>:9090`
- Grafana: Access via `http://<grafana-service>:3000` (default credentials: admin/admin)

## Notes

- This is a sample project for educational purposes
- In a production environment, secrets should be managed securely
- Consider adding more robust monitoring, logging, and security measures
>>>>>>> 6c1b994 (initial commit)
