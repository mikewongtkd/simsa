FROM php:8.1.28-apache
RUN mkdir /usr/local/simsa-build
COPY ./deploy/docker/install.sh /usr/local/simsa-build/install.sh
RUN sh /usr/local/simsa-build/install.sh
WORKDIR /usr/local/simsa
EXPOSE 8321
EXPOSE 3321
#CMD perl /usr/local/simsa/bin/simsa
