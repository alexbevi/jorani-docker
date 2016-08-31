# use 15.10 as 16.04+ no longer contains php5
# see http://askubuntu.com/a/756901
FROM ubuntu:15.10
MAINTAINER alex@alexbevi.com

ENV JORANI_VERSION=0.4.6

RUN apt-get update -y
# silence debconf errors during install
# see http://askubuntu.com/a/506635
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y unzip apache2 php5 libapache2-mod-php5 php5-ldap apache2-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y php5-mysql

RUN php5enmod mcrypt
RUN php5enmod openssl

RUN wget https://github.com/bbalet/jorani/archive/v${JORANI_VERSION}.tar.gz

RUN rm -Rf /var/www/html
RUN tar zxvf v${JORANI_VERSION}.tar.gz
RUN mv /jorani-${JORANI_VERSION} /var/www/html/

RUN rm v${JORANI_VERSION}.tar.gz

RUN a2enmod rewrite

# FIXME the database.php file should come from the untar'd file and
# be dynamically updated (using sed?) to replace the defaults with
# environment variables instead
COPY database.php /var/www/html/application/config/database.php

# Configure Apache2
ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_LOG_DIR      /var/log/apache2
env APACHE_PID_FILE     /var/run/apache2.pid
env APACHE_RUN_DIR      /var/run/apache2
env APACHE_LOCK_DIR     /var/lock/apache2
env APACHE_LOG_DIR      /var/log/apache2

COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

EXPOSE 80
ENTRYPOINT [ "/usr/sbin/apache2", "-DFOREGROUND" ]
