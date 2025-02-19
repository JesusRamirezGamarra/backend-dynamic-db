#!/bin/bash
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_DIR="/backup"
BACKUP_FILE="$BACKUP_DIR/jenkins_backup_$TIMESTAMP.tar.gz"

# Crear el respaldo
mkdir -p $BACKUP_DIR
tar -czvf $BACKUP_FILE /var/jenkins_home

# Subir a S3
aws s3 cp $BACKUP_FILE s3://bucket-codigo-backup/ramirez-alumno/mysql-jenkins/$TIMESTAMP/
