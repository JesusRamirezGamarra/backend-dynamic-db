# Utilizar una imagen base con herramientas para AWS CLI y las herramientas de base de datos necesarias
FROM amazonlinux:2

# Instalar las herramientas necesarias
RUN yum install -y \
    mysql \
    postgresql \
    mongodb-tools \
    aws-cli \
    && yum clean all

# Copiar el script al contenedor
COPY backup-script.sh /usr/local/bin/backup-script.sh

# Darle permisos de ejecución
RUN chmod +x /usr/local/bin/backup-script.sh

# Establecer la entrada del contenedor
ENTRYPOINT ["/usr/local/bin/backup-script.sh"]
