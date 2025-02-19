# 1. Instalacion de Jenkins en digital Ocean


Actualizar los paquetes del sistema:
```
apt update && apt upgrade -y
```
![alt text](image-23.png)

Agregar la clave GPG de Jenkins:
Jenkins requiere una clave GPG para verificar los paquetes descargados. Para agregarla, ejecuta:
```
wget -q -O - https://pkg.jenkins.io/ci.org.key | sudo apt-key add -
```

El error que estás viendo indica que apt-key está obsoleto y que el archivo proporcionado no contiene datos de clave válidos. Para corregirlo, sigue estos pasos para agregar la clave de manera compatible con las versiones más recientes de Ubuntu/Debia
```
wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key

```
Finalmente, actualiza el índice de paquetes e instala Jenkins:


Instalar Java (dependencia de Jenkins):
Jenkins requiere Java para ejecutarse. Puedes instalar OpenJDK 11 (una versión recomendada) con:
```
sudo apt install openjdk-11-jdk -y
```

```
sudo apt update
sudo apt install jenkins -y

```

niciar Jenkins:
```
sudo systemctl start jenkins
```


Ejecuta el siguiente comando para obtener detalles sobre el error:
```
systemctl status jenkins.service
```
![alt text](image-25.png)


```
sudo apt update
sudo apt install openjdk-17-jdk -y
```

Ejecuto :
```
 wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key
--2025-02-17 03:13:24--  https://pkg.jenkins.io/debian/jenkins.io-2023.key
```

Reinicio servicios
```
 sudo systemctl restart jenkins
 ```

verifico errores:
```
 journalctl -xeu jenkins.service --no-pager | tail -50
 ```
 ![alt text](image-26.png)

Inicializo Jenkin-- utilizare de password :
123123
 ![alt text](image-27.png)

 ![alt text](image-28.png)

 ![alt text](image-29.png)

 ![alt text](image-30.png)



 ![alt text](image-31.png)

 ![alt text](image-32.png)




  # 2. Instalar Docker 

Despues de conectarnos a nuestro Droplet de Digital ocen procedemoa  :
```
# Actualiza los repositorios
sudo apt update

# Instala dependencias
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Agrega la clave de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Agrega el repositorio de Docker
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Instala Docker
sudo apt update
sudo apt install docker-ce

# Verifica que Docker esté funcionando
sudo systemctl status docker
```


  # 3. #Instalar Docker Compose

Docker Compose es necesario para definir y ejecutar aplicaciones Docker multi-contenedor. Para instalar Docker Compose, ejecuta:
  ```
# Descarga la última versión de Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Dale permisos de ejecución
sudo chmod +x /usr/local/bin/docker-compose

# Verifica la instalación
docker-compose --version

  ```

 # 4. JOB test de  Pipeline para Probar SSH
  Test exitoso despues de algunos ajustes sobre el codigo.

generar SSH para coniguracion con Digital Ocean
![alt text](image.png)

![alt text](image-1.png)

Se logro probar la comunicacion
![alt text](image-2.png)



# TEST - Forna 2 // Otra alternativa con imagen 

# 1. Configurar el Servidor Digital Ocean (Droplet)



```
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
newgrp docker

```

![alt text](image-3.png)

Crear el Dockerfile para Jenkins
Se modificará el Dockerfile para incluir kubectl y AWS CLI.


```
FROM jenkins/jenkins:lts-jdk17

USER root

# Instalar Docker dentro del contenedor
RUN apt update && apt install -y docker.io

# Instalar kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Instalar AWS CLI
RUN apt install -y unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Agregar jenkins al grupo docker
RUN usermod -aG docker jenkins

USER jenkins
```

 Crear el docker-compose.yml
 Este archivo definirá el servicio de Jenkins con volúmenes y conexión a Docker.

```
version: '3.8'
services:
  jenkins:
    build: .
    container_name: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
volumes:
  jenkins_home:
```

Configurar Conexión de Jenkins con Kubernetes En Jenkins Instalar plugins:

```
Kubernetes CLI
Docker Pipeline
Pipeline: AWS Steps (para usar AWS CLI)

```
Configurar credenciales en Jenkins:

```
Agregar las credenciales de Kubernetes (archivo kubeconfig.yaml)
Agregar credenciales de AWS para S3 (AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY)

```

Pipeline en Jenkins ( todo en uno )
```
pipeline {
    agent any
    environment {
        KUBECONFIG = credentials('k8s-config')
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id-s3')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key-s3')
    }
    stages {
        stage('Probar conexión') {
            steps {
                sh 'kubectl get pods'
            }
        }
        stage('Configurar credenciales AWS') {
            steps {
                sh '''
                mkdir -p ~/.aws
                echo "[default]" > ~/.aws/credentials
                echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> ~/.aws/credentials
                echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> ~/.aws/credentials
                chmod 600 ~/.aws/credentials
                '''
            }
        }
        stage('Generar Backup') {
            steps {
                sh '''
                TIMESTAMP=$(date +"%Y%m%d%H%M%S")
                BACKUP_FILE="jenkins_backup_$TIMESTAMP.tar.gz"
                tar -czvf $BACKUP_FILE /var/jenkins_home
                echo "Backup generado: $BACKUP_FILE"
                echo "BACKUP_FILE=$BACKUP_FILE" >> $WORKSPACE/env_vars
                '''
            }
        }
        stage('Subir backup a S3') {
            steps {
                sh '''
                source $WORKSPACE/env_vars
                aws s3 cp $BACKUP_FILE s3://bucket-codigo-backup/ramirez/MYSQL-jenkins/$TIMESTAMP/
                '''
            }
        }
    }
}

```
Escenario para utilizar una imagen para el backup
Configurar Respaldo Automático a AWS S3 Se creará un contenedor que haga el respaldo del volumen jenkins_home y lo suba a S3 cada 3 horas.

dockerfile
```
FROM amazonlinux:latest

RUN yum install -y aws-cli tar gzip

CMD ["/bin/bash", "-c", "while true; do sleep 10800; /backup.sh; done"]
```
Crear el script de backup Crear un archivo backup.sh:
```
#!/bin/bash
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_DIR="/backup"
BACKUP_FILE="$BACKUP_DIR/jenkins_backup_$TIMESTAMP.tar.gz"

# Crear el respaldo
mkdir -p $BACKUP_DIR
tar -czvf $BACKUP_FILE /var/jenkins_home

# Subir a S3
aws s3 cp $BACKUP_FILE s3://bucket-codigo-backup/ramirez/MYSQL-jenkins/$TIMESTAMP/
```
Crear el docker-compose.yml para el backup
```
version: '3.8'
services:
  backup:
    build: .
    container_name: backup
    environment:
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    volumes:
      - jenkins_home:/var/jenkins_home
    restart: unless-stopped
volumes:
  jenkins_home:
```
![alt text](image-5.png)
![alt text](image-4.png)
![alt text](image-6.png)