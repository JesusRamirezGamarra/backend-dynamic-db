// pipeline {
//     agent any
//     stages {
//         stage('Test Kubernetes Connection') {
//             steps {
//                 script {
//                     sh 'kubectl get nodes'
//                 }
//             }
//         }
//     }
// }
pipeline {
    agent any
    environment {
        AWS_BUCKET = 'bucket-codigo-backup'
        BACKUP_PATH = 'codigo/jesusramirez/database-jenkins/'
    }
    stages {
        stage('Clonar Repositorio') {
            steps {
                git branch: 'jenkins', 
                    credentialsId: 'github-token', 
                    url: 'https://github.com/JesusRamirezGamarra/backend-dynamic-db.git'
            }
        }
        stage('Detener Servicios') {
            steps {
                sh 'docker-compose down'
            }
        }
        stage('Actualizar Código') {
            steps {
                sh 'docker-compose pull'
            }
        }
        stage('Levantar Servicios') {
            steps {
                sh 'docker-compose up -d'
            }
        }
    }
}
