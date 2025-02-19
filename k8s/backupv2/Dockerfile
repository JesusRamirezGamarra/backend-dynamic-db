FROM amazonlinux:latest

RUN yum install -y aws-cli tar gzip

CMD ["/bin/bash", "-c", "while true; do sleep 10800; /backup.sh; done"]
