# 1. Github Actions

INicialmente hice la forma con imagenes independeciente que explioque en mi expo pero como no lo tengo documento y el tiempo se vence dejo el codigo en el proyecto y docymento una q es mas sencilla 
q es la forma  maso recomendada en terminos de menos pasos


## 1.: Crear el ConfigMap en Kubernetes

El ConfigMap permitirá almacenar y modificar la configuración del driver de base de datos en Kubernetes.
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
  namespace: backend
data:
  DB_DRIVER: "mysql"

```

Aplicarlo en Kubernetes: probamos aplicarlo directmaente para no bajar la intancia total para comprobar que podemos hacer estos cambios inbcluso secrets deployments y demas en fin.

![alt text](image.png)

```
kubectl apply -f db-configmap.yaml
```

## 2: Crear un Pipeline en Jenkins
El siguiente Jenkinsfile permitirá hacer el cambio de driver en Kubernetes o en el Droplet de Digital Ocean según el recurso seleccionado.
La intencon es 
a) El usuario elige en Jenkins si quiere cambiar el driver en Digital Ocean o en Kubernetes.
B) Si elige Kubernetes (k8):

Logrando que
- Se actualiza la variable DB_DRIVER en el ConfigMap.
- Se reinicia el Deployment de backend-api.
- Si elige Digital Ocean (digital-ocean):
- Se actualiza la variable de entorno en /etc/environment.
- Se usa ssh para modificar la configuración en el Droplet.
- Se verifica el cambio ejecutando kubectl get configmap en Kubernetes o cat /etc/environment en Digital Ocean.


definimos algunas variables adicionales comos secrets
Antes de ejecutar el pipeline, configura las siguientes variables en Jenkins:

A ) Credenciales de Kubernetes

Tipo: Secret file
ID: k8s-config
Descripción: Credenciales para acceder a Kubernetes

B ) Credenciales SSH para Digital Ocean

Tipo: SSH Username with private key
ID: digital-ocean-ssh
Descripción: Acceso SSH al Droplet de Digital Ocean
Variables Globales en Jenkins (Manage Jenkins > Configure System)

C) Agrega las siguientes variables en la sección Global properties:

DO_SERVER_IP: 157.230.200.12 (IP del Droplet de Digital Ocean)
DO_USER: root (Usuario SSH en el Droplet)
AWS_ACCESS_KEY_ID: AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY: AWS_SECRET_ACCESS_KEY

```
pipeline {
    agent any
    parameters {
        choice(name: 'RECURSO', choices: ['digital-ocean', 'k8'], description: 'Selecciona el recurso donde cambiar el driver')
        choice(name: 'DRIVER', choices: ['mysql', 'postgres', 'mongo'], description: 'Selecciona el driver de base de datos')
    }
    environment {
        KUBECONFIG = credentials('k8s-config')
        DO_SERVER_IP = "${env.DO_SERVER_IP}"
        DO_USER = "${env.DO_USER}"
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id-s3')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key-s3')
    }
    stages {
        stage('Verificar Parámetros') {
            steps {
                script {
                    echo "Recurso seleccionado: ${params.RECURSO}"
                    echo "Driver seleccionado: ${params.DRIVER}"
                }
            }
        }

        stage('Actualizar Driver en Kubernetes') {
            when {
                expression { params.RECURSO == 'k8' }
            }
            steps {
                sh '''
                kubectl set env deployment/backend-api -n backend DB_DRIVER=${DRIVER}
                kubectl rollout restart deployment backend-api -n backend
                echo "Driver cambiado en Kubernetes a: ${DRIVER}"
                '''
            }
        }

        stage('Actualizar Driver en Digital Ocean') {
            when {
                expression { params.RECURSO == 'digital-ocean' }
            }
            steps {
                sh '''
                ssh -o StrictHostKeyChecking=no ${DO_USER}@${DO_SERVER_IP} << 'EOF'
                export DB_DRIVER=${DRIVER}
                echo "DB_DRIVER=${DRIVER}" > /etc/environment
                source /etc/environment
                echo "Driver cambiado en Digital Ocean a: ${DRIVER}"
                EOF
                '''
            }
        }

        stage('Verificar Configuración') {
            steps {
                script {
                    if (params.RECURSO == 'k8') {
                        sh 'kubectl get configmap db-config -n backend -o yaml | grep DB_DRIVER'
                    } else {
                        sh '''
                        ssh -o StrictHostKeyChecking=no ${DO_USER}@${DO_SERVER_IP} "cat /etc/environment | grep DB_DRIVER"
                        '''
                    }
                }
            }
        }
    }
}
```

Probar el Cambio de Driver
Ejecuta el pipeline en Jenkins y selecciona:

Recurso: k8
Driver: postgres
Verifica en Kubernetes:
```
kubectl get configmap db-config -n backend -o yaml
```



