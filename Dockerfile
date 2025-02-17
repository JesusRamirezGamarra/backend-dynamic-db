# # Usar una imagen base de Ubuntu
# FROM ubuntu:20.04

# # Establecer el directorio de trabajo en el contenedor
# WORKDIR /app

# # Actualizar los repositorios de apt-get y asegurarse de que el sistema esté limpio
# RUN apt-get update -y && apt-get upgrade -y

# # Diagnóstico: verificar la versión de apt-get y los repositorios disponibles
# RUN apt-get --version
# RUN apt-cache policy

# # Instalar dependencias necesarias para Node.js y herramientas de respaldo
# RUN apt-get install -y \
#     curl \
#     gnupg \
#     lsb-release \
#     mysql-client \
#     postgresql-client \
#     mongodb-tools \
#     awscli \
#     nodejs \
#     npm \
#     && apt-get clean

# # Instalar las dependencias de Node.js
# COPY package*.json ./
# RUN npm install

# # Copiar el resto del código de la aplicación
# COPY . .

# # Copiar el script de backup al contenedor
# COPY k8s/backup/script/backup-script.sh /usr/local/bin/backup-scripts/backup-script.sh

# # Exponer el puerto en el que correrá la aplicación
# EXPOSE 3000

# # Definir la variable de entorno por defecto para la base de datos (puede ser sobrescrita)
# ENV MY_DATABASE_DRIVER=mysql

# # Comando para ejecutar la aplicación
# CMD ["node", "index.js"]



# # # Usar Amazon Linux 2 como imagen base
# # FROM amazonlinux:2

# # # Establecer el directorio de trabajo en el contenedor
# # WORKDIR /app

# # # Actualizar e instalar las herramientas necesarias
# # RUN yum update -y && yum install -y \
# #     mysql \
# #     postgresql \
# #     mongodb-tools \
# #     aws-cli \
# #     nodejs \
# #     npm \
# #     && yum clean all

# # # Instalar las dependencias de Node.js
# # COPY package*.json ./
# # RUN npm install

# # # Copiar el resto del código de la aplicación
# # COPY . .

# # # Copiar el script de backup al contenedor
# # COPY k8s/backup/script/backup-script.sh /usr/local/bin/backup-scripts/backup-script.sh

# # # Exponer el puerto en el que correrá la aplicación
# # EXPOSE 3000

# # # Definir la variable de entorno por defecto para la base de datos (puede ser sobrescrita)
# # ENV MY_DATABASE_DRIVER=mysql

# # # Comando para ejecutar la aplicación
# # CMD ["node", "index.js"]





# # # # # Usar una imagen base oficial de Node.js
# # # # FROM node:18

# # # # # Establecer el directorio de trabajo en el contenedor
# # # # WORKDIR /app

# # # # # Copiar los archivos del proyecto al contenedor
# # # # COPY package*.json ./

# # # # # Instalar las dependencias
# # # # RUN npm install

# # # # # Copiar el resto del código de la aplicación
# # # # COPY . .

# # # # # Exponer el puerto en el que correrá la aplicación
# # # # EXPOSE 3000

# # # # # Definir la variable de entorno por defecto para la base de datos (puede ser sobrescrita)
# # # # ENV MY_DATABASE_DRIVER=mysql

# # # # # Comando para ejecutar la aplicación
# # # # CMD ["node", "index.js"]

# # # # Usar una imagen base oficial de Node.js




FROM node:23

# Establecer el directorio de trabajo en el contenedor
WORKDIR /app

# Copiar los archivos del proyecto al contenedor
COPY package*.json ./ 

# Actualizar los repositorios de apt-get y asegurarse de que el sistema esté limpio
RUN apt-get update -y && apt-get upgrade -y

# Instalar herramientas para respaldo y AWS CLI
# RUN apt-get update && apt-get install -y \
#     mysql-client \
#     # postgresql-client \
#     # mongodb-tools \
#     # aws-cli \
#     && apt-get clean

# Instalar las dependencias de Node.js
RUN npm install

# Copiar el resto del código de la aplicación
COPY . .

# Crear la carpeta destino dentro del contenedor
RUN mkdir -p /usr/local/bin/backup-scripts

# Copiar el script desde el directorio `k8s/scripts/`
COPY k8s/backup/script/backup-script.sh /usr/local/bin/backup-scripts/backup-script.sh

# Dar permisos de ejecución al script
RUN chmod +x /usr/local/bin/backup-scripts/backup-script.sh


# Exponer el puerto en el que correrá la aplicación
EXPOSE 3000

# Definir la variable de entorno por defecto para la base de datos (puede ser sobrescrita)
ENV MY_DATABASE_DRIVER=mysql

# Comando para ejecutar la aplicación
CMD ["node", "index.js"]