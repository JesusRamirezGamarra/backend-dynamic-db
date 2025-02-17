pipeline {
    agent any
    stages {
        stage('Test Kubernetes Connection') {
            steps {
                script {
                    sh 'kubectl get nodes'
                }
            }
        }
    }
}
// pipeline {
//     agent any
//     environment {
//         DOCKER_COMPOSE_PATH = '/usr/local/bin/docker-compose'  // Ruta de Docker Compose
//     }
//     stages {
//         stage('Checkout') {
//             steps {
//                 git 'https://github.com/tu_usuario/tu_repositorio.git'
//             }
//         }
//         stage('Build Docker Images') {
//             steps {
//                 script {
//                     // Asegúrate de que el archivo docker-compose.yml esté en la raíz del proyecto
//                     sh 'docker-compose -f docker-compose.yml build'
//                 }
//             }
//         }
//         stage('Push Docker Images') {
//             steps {
//                 script {
//                     // Este paso solo se hace si necesitas subir las imágenes a un repositorio
//                     // (por ejemplo, Docker Hub)
//                     docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
//                         sh 'docker-compose -f docker-compose.yml push'
//                     }
//                 }
//             }
//         }
//         stage('Deploy to Kubernetes') {
//             steps {
//                 script {
//                     // Asegúrate de tener configurado kubectl para interactuar con tu clúster de Kubernetes
//                     sh 'kubectl apply -f k8s/deployment.yaml'
//                 }
//             }
//         }
//     }
//     post {
//         success {
//             echo 'Despliegue completado exitosamente!'
//         }
//         failure {
//             echo 'Hubo un error en el despliegue.'
//         }
//     }
// }