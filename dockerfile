# FROM jenkins/jenkins:lts-jdk17

# USER root

# RUN apt update && apt install -y docker.io

# RUN usermod -aG docker jenkins

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
