FROM ubuntu:latest
ENV CLOUD_SDK_VERSION 165.0.0
ENV CLOUD_SDK_REPO cloud-sdk-trusty

RUN apt-get update && apt-get -y install gnupg curl software-properties-common nano

# MongoDB Tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
RUN echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list

# GLCOUD
RUN echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl http://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Neo
RUN echo 'deb https://debian.neo4j.org/repo stable/' | tee -a /etc/apt/sources.list.d/neo4j.list
RUN curl https://debian.neo4j.org/neotechnology.gpg.key | apt-key add -

RUN apt-get update && apt-get -y install cron \
    openssh-client \
    apt-transport-https \
    mongodb-org \
    python-setuptools \
    python-dev \
    build-essential \
    postgresql-client \
    google-cloud-sdk \
    openjdk-8-jdk \
    neo4j-enterprise=1:3.4.1 \
    unzip

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Cron
RUN mkdir /cronjobs && mkdir /cronjobs/backups

# pip
RUN apt-get -y install python-pip
RUN python2.7 -m pip install -U setuptools
RUN pip install requests

# Backups
RUN mkdir /cronjobs/backups/mongo
RUN mkdir /cronjobs/backups/mongo-ct
RUN mkdir /cronjobs/backups/postgres
RUN mkdir /cronjobs/backups/neo4j
COPY automongobackup.sh /cronjobs/automongobackup.sh
COPY automongoctbackup.sh /cronjobs/automongoctbackup.sh
COPY autoelasticbackup.sh /cronjobs/autoelasticbackup.sh
COPY autopostgresbackup.sh /cronjobs/autopostgresbackup.sh
COPY autoneobackup.sh /cronjobs/autoneobackup.sh

# Create the log file to be able to run tail
RUN touch /var/log/cron.log
RUN touch /var/log/cron-check.log

COPY entrypoint.sh /cronjobs/entrypoint.sh
WORKDIR /cronjobs

# Run the command on container startup
ENTRYPOINT ["./entrypoint.sh"]
