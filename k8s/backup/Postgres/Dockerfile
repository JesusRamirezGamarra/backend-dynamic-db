#!/bin/bash

# Usa Ubuntu 22.04 como imagen base
FROM ubuntu:22.04

# Establecer la carpeta de trabajo dentro del contenedor
WORKDIR /usr/local/bin/backup-scripts

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    tar \
    gzip \
    curl \
    unzip

# Agregar el repositorio de PostgreSQL 14 y desactivar GPG check temporalmente
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Actualizar el cache de paquetes y asegurar la instalación
RUN apt-get update && apt-get install -y postgresql-client-14

# Instalar AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Verificar la instalación de AWS CLI
RUN aws --version

# Crear la carpeta donde se ubicará el script de backup y establecer permisos
RUN mkdir -p /usr/local/bin/backup-scripts && chmod 755 /usr/local/bin/backup-scripts

# Copiar el script de backup dentro del contenedor
COPY script/backup-script.sh /usr/local/bin/backup-scripts/backup-script.sh

# Dar permisos de ejecución al script y verificar que existe
RUN chmod +x /usr/local/bin/backup-scripts/backup-script.sh && \
    ls -l /usr/local/bin/backup-scripts/backup-script.sh

# Crear un usuario no root
RUN useradd -m backupuser

# Asignar permisos al usuario no root para ejecutar el script
RUN chown -R backupuser:backupuser /usr/local/bin/backup-scripts

# Cambiar al usuario no root
USER backupuser

# Comando de inicio
CMD ["/usr/local/bin/backup-scripts/backup-script.sh"]
