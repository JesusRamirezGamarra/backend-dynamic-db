#!/bin/bash

# Obtener la fecha y hora actual en formato YYYYMMDDHHMMSS
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Definir la base de datos, el nombre del bucket y la ruta
AWS_BUCKET="s3://bucket-codigo-backup/ramirez"
DB_NAME=$1  # Nombre de la base de datos (MYSQL/PostgreSQL/MongoDB) también se usará para DB_TYPE

# Asignar DB_TYPE igual a DB_NAME
DB_TYPE=$DB_NAME

# Nombre de la subcarpeta para la base de datos
DB_PATH="${AWS_BUCKET}/${DB_TYPE}/${TIMESTAMP}"

# Conectar y exportar la base de datos dependiendo del tipo
if [ "$DB_TYPE" == "MYSQL" ]; then
    # Exportar la base de datos MySQL
    mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $DB_NAME > /tmp/${DB_NAME}_backup.sql
    aws s3 cp /tmp/${DB_NAME}_backup.sql ${DB_PATH}/BD_backup.sql

elif [ "$DB_TYPE" == "POSTGRES" ]; then
    # Exportar la base de datos PostgreSQL
    pg_dump -U $POSTGRES_USER -h $POSTGRES_HOST -p $POSTGRES_PORT $DB_NAME > /tmp/${DB_NAME}_backup.sql
    aws s3 cp /tmp/${DB_NAME}_backup.sql ${DB_PATH}/BD_backup.sql

elif [ "$DB_TYPE" == "MONGODB" ]; then
    # Exportar la base de datos MongoDB
    mongodump --uri=mongodb://$MONGO_USER:$MONGO_PASSWORD@$MONGO_HOST:$MONGO_PORT/$DB_NAME --out /tmp/${DB_NAME}_backup
    aws s3 cp /tmp/${DB_NAME}_backup ${DB_PATH}/BD_backup --recursive

else
    echo "Base de datos no soportada. Opciones: MYSQL, POSTGRES, MONGODB"
    exit 1
fi

# Eliminar los archivos temporales
rm -rf /tmp/${DB_NAME}_backup*
