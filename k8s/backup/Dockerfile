# Usamos una imagen base de Amazon Linux 2 que tiene AWS CLI
FROM amazonlinux:2

# Instalar las dependencias necesarias
RUN yum install -y \
    mysql \
    postgresql \
    mongodb-tools \
    aws-cli \
    && yum clean all

# Crear el directorio para el script de respaldo
RUN mkdir -p /usr/local/bin/backup-scripts

# Copiar el script al contenedor
COPY Script/backup-script.sh /usr/local/bin/backup-scripts/backup-script.sh

# Darle permisos de ejecución al script
RUN chmod +x /usr/local/bin/backup-scripts/backup-script.sh

# Configurar la imagen para que ejecute el script al iniciarse
ENTRYPOINT ["/usr/local/bin/backup-scripts/backup-script.sh"]