FROM ubuntu
RUN apt-get upgrade && apt-get update && apt-get install -y python3 python3-pip

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt
## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

## preesed tzdata, update package index, upgrade packages and install needed software
RUN echo "tzdata tzdata/Areas select America" > /tmp/preseed.txt; \
    echo "tzdata tzdata/Zones/America select New_York" >> /tmp/preseed.txt; \
    debconf-set-selections /tmp/preseed.txt && \
    rm -f /etc/timezone && \
    rm -f /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata

## cleanup of files from setup
RUN rm -rf /tmp/* /var/tmp/*
RUN apt-get install -y imagemagick poppler-utils
COPY . .

# remove useage restrictions on convert
RUN mv /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xmlout
RUN apt-get install sqlite3
RUN sqlite3 as.db < schema.sql

#install mongodb
RUN apt-get install -y wget 
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - 
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.2.list 
RUN apt-get update 
RUN apt-get install -y mongodb-server

CMD ./run_all.sh