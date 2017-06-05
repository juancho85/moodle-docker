FROM php:7.1-apache

ADD config/ /
RUN /php-extensions.sh

# For some reason we do need en_US here..
RUN mkdir /var/www/moodledata

COPY /config/config.docker-template.php /var/www/moodledata/config.php

RUN chown -R www-data /var/www/moodledata/ && chmod -R 777 /var/www/moodledata/
