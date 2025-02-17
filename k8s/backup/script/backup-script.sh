#!/bin/sh

# Obtener la fecha y hora actual en formato YYYYMMDDHHMMSS
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Definir la variable del bucket AWS
AWS_BUCKET="s3://bucket-codigo-backup/ramirez"
export AWS_REGION="us-east-1"
# DB_NAME=$1  # Nombre de la base de datos
# DB_TYPE=$2  # Tipo de base de datos (MYSQL, POSTGRES, MONGODB)
DB_NAME=${1:-"testdb"}  # Si no se pasa, usa "testdb"
DB_TYPE=${2:-"MYSQL"}    # Si no se pasa, usa

# Validar que `DB_TYPE` solo contenga valores permitidos
if [ "$DB_TYPE" != "MYSQL" ] && [ "$DB_TYPE" != "POSTGRES" ] && [ "$DB_TYPE" != "MONGODB" ]; then
    echo "❌ Error: Tipo de base de datos no soportado ($DB_TYPE). Usa MYSQL, POSTGRES o MONGODB."
    exit 1
fi


# Instalar AWS CLI si no está presente
if ! command -v aws &> /dev/null; then
    echo "📌 Instalando AWS CLI..."
    yum install -y aws-cli
fi

# Nombre de la subcarpeta en S3
DB_PATH="${AWS_BUCKET}/${DB_TYPE}/${TIMESTAMP}"
echo "📌 Usando DB_NAME=${DB_NAME}, DB_TYPE=${DB_TYPE}"
# Validar que se pasen los parámetros correctos
if [ -z "$DB_NAME" ]; then
    echo "❌ Error: Debes proporcionar el nombre de la base de datos (catalogo)."
    # DB_NAME="testdb" 
    echo  "📌 Tipo de base de datos no definido. Usando $DB_NAME por defecto."
    # exit 1
fi

# Si no se definió DB_TYPE, usar la variable de entorno
if [ -z "$DB_TYPE" ]; then
    echo "❌ Error: Debes proporcionar el nombre de la base de datos y el tipo (MYSQL, POSTGRES, MONGODB)."
    # DB_TYPE="MYSQL"
    echo "📌 Tipo de base de datos no definido. Usando $DB_TYPE por defecto."
fi

# Configurar conexión y exportar la base de datos
if [ "$DB_TYPE" = "MYSQL" ]; then
    echo "📌 Respaldando MySQL..."
    
    # Verificar que mysqldump está instalado
    if ! command -v mysqldump &> /dev/null; then
        echo "⚠️ Instalando MySQL Client..."
        yum install -y mysql-community-client
    fi

    # Crear archivo de credenciales temporales
    MYSQL_CNF=$(mktemp)
    echo "[client]" > "$MYSQL_CNF"
    echo "user=$MYSQL_USER" >> "$MYSQL_CNF"
    echo "password=$MYSQL_PASSWORD" >> "$MYSQL_CNF"
    echo "host=${MYSQL_HOST:-mysql-service}" >> "$MYSQL_CNF"
    echo "port=${MYSQL_PORT:-3306}" >> "$MYSQL_CNF"

    # Exportar base de datos MySQL
    mysqldump --defaults-extra-file="$MYSQL_CNF" --databases "$DB_NAME" | gzip > "/tmp/${DB_NAME}_backup.sql.gz"

    # Subir a S3
    aws s3 cp "/tmp/${DB_NAME}_backup.sql.gz" "${DB_PATH}/BD_backup.sql.gz" --region "$AWS_REGION" 

    # Eliminar credenciales temporales
    rm -f "$MYSQL_CNF"

elif [ "$DB_TYPE" = "POSTGRES" ]; then
    echo "📌 Respaldando PostgreSQL..."
    
    # Verificar que pg_dump está instalado
    if ! command -v pg_dump &> /dev/null; then
        echo "⚠️ Instalando PostgreSQL Client..."
        yum install -y postgresql
    fi

    # Exportar base de datos PostgreSQL
    export PGPASSWORD="$POSTGRES_PASSWORD"
    pg_dump -U "$POSTGRES_USER" -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" "$DB_NAME" | gzip > "/tmp/${DB_NAME}_backup.sql.gz"

    # Subir a S3
    aws s3 cp "/tmp/${DB_NAME}_backup.sql.gz" "${DB_PATH}/BD_backup.sql.gz" --region "$AWS_REGION" 

elif [ "$DB_TYPE" = "MONGODB" ]; then
    echo "📌 Respaldando MongoDB..."
    
    # Verificar que mongodump está instalado
    if ! command -v mongodump &> /dev/null; then
        echo "⚠️ Instalando MongoDB Tools..."
        yum install -y mongodb-org-tools
    fi

    # Exportar base de datos MongoDB
    mongodump --uri="mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/${DB_NAME}" --out "/tmp/${DB_NAME}_backup"
    
    # Subir a S3
    aws s3 cp "/tmp/${DB_NAME}_backup" "${DB_PATH}/BD_backup" --recursive --region "$AWS_REGION" 

else
    echo "❌ Error: Tipo de base de datos no soportado. Usa MYSQL, POSTGRES o MONGODB."
    exit 1
fi

# Limpiar archivos temporales
rm -rf /tmp/${DB_NAME}_backup*

echo "✅ Respaldo completado correctamente en ${DB_PATH}"













# # # Obtener la fecha y hora actual en formato YYYYMMDDHHMMSS
# # TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# # # Definir la variable del bucket AWS
# # AWS_BUCKET="s3://bucket-codigo-backup/ramirez"
# # DB_NAME=$1  # Nombre de la base de datos (MYSQL/PostgreSQL/MongoDB)
# # DB_TYPE=$2  # Tipo de base de datos (MYSQL, POSTGRES, MONGODB)

# # echo "Instalando AWS CLI..."
# # yum install -y aws-cli
# # # Verifica si los comandos están instalados
# # if [ "$DB_TYPE" == "MYSQL" ]; then
# #     echo "Instalando MySQL Client..."
# #     yum install -y mysql
# # fi

# # # Nombre de la subcarpeta para la base de datos
# # DB_PATH="${AWS_BUCKET}/database/${TIMESTAMP}"

# # # Si la variable MY_DATABASE_DRIVER no está definida, usar la base de datos MySQL por defecto
# # if [ -z "$DB_TYPE" ]; then
# #     DB_TYPE=$MY_DATABASE_DRIVER
# # fi

# # # Conectar y exportar la base de datos dependiendo del tipo
# # if [ "$DB_TYPE" == "MYSQL" ]; then
# #     # Exportar la base de datos MySQL
# #     mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD $DB_NAME > /tmp/${DB_NAME}_backup.sql
# #     aws s3 cp /tmp/${DB_NAME}_backup.sql ${DB_PATH}/BD_backup.sql

# # elif [ "$DB_TYPE" == "POSTGRES" ]; then
# #     # Exportar la base de datos PostgreSQL
# #     pg_dump -U $POSTGRES_USER -h $POSTGRES_HOST -p $POSTGRES_PORT $DB_NAME > /tmp/${DB_NAME}_backup.sql
# #     aws s3 cp /tmp/${DB_NAME}_backup.sql ${DB_PATH}/BD_backup.sql

# # elif [ "$DB_TYPE" == "MONGODB" ]; then
# #     # Exportar la base de datos MongoDB
# #     mongodump --uri=mongodb://$MONGO_USER:$MONGO_PASSWORD@$MONGO_HOST:$MONGO_PORT/$DB_NAME --out /tmp/${DB_NAME}_backup
# #     aws s3 cp /tmp/${DB_NAME}_backup ${DB_PATH}/BD_backup --recursive

# # else
# #     echo "Base de datos no soportada. Opciones: MYSQL, POSTGRES, MONGODB"
# #     exit 1
# # fi

# # # Eliminar los archivos temporales
# # rm -rf /tmp/${DB_NAME}_backup*




