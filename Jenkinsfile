pipeline {
    agent {
        docker {
            image 'jenkins/jenkins:lts-jdk17'
            args '--user root'
        }
    }
    environment {
        KUBECONFIG = credentials('k8s-config')
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    }
    stages {
        stage('Clonar Repositorio') {
            steps {
                git 'https://github.com/JesusRamirezGamarra/backend-dynamic-db.git'
            }
        }
        stage('Construir Imagen Docker') {
            steps {
                sh 'docker build -t backend-api:latest .'
            }
        }
        stage('Publicar Imagen en Docker Hub') {
            steps {
                //sh 'docker tag backend-api:latest jesusramirezgamarra/backend-api:latest'
                //sh 'docker push jesusramirezgamarra/backend-api:latest'
                //sh 'docker push jesusramirezgamarra/mysql-backup"
            }
        }
        stage('Desplegar en Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }
        stage('Verificar Despliegue') {
            steps {
                sh 'kubectl get pods'
            }
        }
    }
}
