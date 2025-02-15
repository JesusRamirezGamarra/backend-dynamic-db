# Usar una imagen base oficial de Node.js
FROM node:18

# Establecer el directorio de trabajo en el contenedor
WORKDIR /app

# Copiar los archivos del proyecto al contenedor
COPY package*.json ./

# Instalar las dependencias
RUN npm install

# Copiar el resto del código de la aplicación
COPY . .

# Exponer el puerto en el que correrá la aplicación
EXPOSE 3000

# Definir la variable de entorno por defecto para la base de datos (puede ser sobrescrita)
ENV MY_DATABASE_DRIVER=mysql

# Comando para ejecutar la aplicación
CMD ["node", "index.js"]
