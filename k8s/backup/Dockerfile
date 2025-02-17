# # Usamos una imagen base de Amazon Linux 2 que tiene AWS CLI
# FROM amazonlinux:2

# # Instalar las dependencias necesarias
# RUN yum install -y \
#     mysql \
#     postgresql \
#     mongodb-tools \
#     aws-cli \
#     && yum clean all

# # Crear el directorio para el script de respaldo
# RUN mkdir -p /usr/local/bin/backup-scripts

# # Copiar el script al contenedor
# COPY Script/backup-script.sh /usr/local/bin/backup-scripts/backup-script.sh

# # Darle permisos de ejecución al script
# RUN chmod +x /usr/local/bin/backup-scripts/backup-script.sh

# # Configurar la imagen para que ejecute el script al iniciarse
# ENTRYPOINT ["/usr/local/bin/backup-scripts/backup-script.sh"]


# # FROM amazonlinux:latest

# # # Instalar dependencias necesarias
# # RUN yum install -y tar gzip mysql

# # # Crear la carpeta donde se ubicará el script de backup
# # RUN mkdir -p /usr/local/bin/backup-scripts

# # # Copiar el script de backup al contenedor
# # COPY script/backup-script.sh /usr/local/bin/backup-scripts/backup-script.sh

# # # Dar permisos de ejecución al script
# # RUN chmod +x /usr/local/bin/backup-scripts/backup-script.sh

# # # Definir el comando por defecto
# # CMD ["/usr/local/bin/backup-scripts/backup-script.sh"]









# # Usa Amazon Linux 2023 como imagen base
# FROM amazonlinux:latest

# # Instalar herramientas necesarias
# RUN yum install -y tar gzip shadow-utils

# # Agregar el repositorio oficial de MySQL 8.0 y desactivar GPG check temporalmente
# RUN yum install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm

# # Descargar manualmente la clave GPG de MySQL para evitar errores
# RUN rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

# # Instalar MySQL Client sin verificación GPG (opcional)
# RUN yum install -y --nogpgcheck mysql-community-client

# # Crear la carpeta donde se ubicará el script de backup y establecer permisos
# RUN mkdir -p /usr/local/bin/backup-scripts && chmod 755 /usr/local/bin/backup-scripts

# # Copiar el script de backup al contenedor
# COPY script/backup-script.sh /usr/local/bin/backup-scripts/backup-script.sh

# # Dar permisos de ejecución al script
# RUN chmod +x /usr/local/bin/backup-scripts/backup-script.sh

# # Instalar `shadow-utils` y crear un usuario no root
# RUN useradd -m backupuser

# # Cambiar al usuario no root
# USER backupuser

# # Establecer el comando de inicio
# CMD ["/usr/local/bin/backup-scripts/backup-script.sh"]











# Usa Amazon Linux 2023 como imagen base
FROM amazonlinux:latest

# Establecer la carpeta de trabajo dentro del contenedor
WORKDIR /usr/local/bin/backup-scripts

# Instalar herramientas necesarias
RUN yum install -y tar gzip shadow-utils

# Agregar el repositorio oficial de MySQL 8.0 y desactivar GPG check temporalmente
RUN yum install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm

# Descargar manualmente la clave GPG de MySQL para evitar errores
RUN rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023

# Instalar MySQL Client sin verificación GPG
RUN yum install -y --nogpgcheck mysql-community-client

# Crear la carpeta donde se ubicará el script de backup y establecer permisos
RUN mkdir -p /usr/local/bin/backup-scripts && chmod 755 /usr/local/bin/backup-scripts

# Copiar el script de backup dentro del contenedor
COPY script/backup-script.sh /usr/local/bin/backup-scripts/backup-script.sh

# Dar permisos de ejecución al script y verificar que existe
RUN chmod +x /usr/local/bin/backup-scripts/backup-script.sh && \
    ls -l /usr/local/bin/backup-scripts/backup-script.sh

# Instalar `shadow-utils` y crear un usuario no root
RUN useradd -m backupuser

# Asignar permisos al usuario no root para ejecutar el script
RUN chown -R backupuser:backupuser /usr/local/bin/backup-scripts

# Cambiar al usuario no root
USER backupuser

# Comando de inicio
CMD ["/usr/local/bin/backup-scripts/backup-script.sh"]