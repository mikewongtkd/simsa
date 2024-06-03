FROM php:8.1.28-apache
RUN mkdir /usr/local/shinsa-build
COPY ./deploy/docker/install.sh /usr/local/shinsa-build/install.sh
RUN sh /usr/local/shinsa-build/install.sh
WORKDIR /usr/local/shinsa
EXPOSE 8321
EXPOSE 3321
CMD perl /usr/local/shinsa/bin/shinsa.pl
