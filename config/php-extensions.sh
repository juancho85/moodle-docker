#!/usr/bin/env bash

set -e

echo "Installing apt depdencies"

BUILD_PACKAGES="gettext libcurl4-openssl-dev libpq-dev libmysqlclient-dev libldap2-dev libxslt-dev \
    libxml2-dev libicu-dev libfreetype6-dev libjpeg62-turbo-dev libmemcached-dev \
    zlib1g-dev libpng12-dev unixodbc-dev apt-transport-https"

LIBS="locales libaio1 libcurl3 libgss3 libicu52 libmysqlclient18 libpq5 libmemcached11 libmemcachedutil2 libldap-2.4-2 libxml2 libxslt1.1 unixodbc libmcrypt-dev"

apt-get update
apt-get install -y --no-install-recommends $BUILD_PACKAGES $LIBS unzip ghostscript locales
echo 'Generating locales..'
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
echo 'en_AU.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

echo "Installing php extensions"
docker-php-ext-install -j$(nproc) \
    intl \
    mysqli \
    opcache \
    pgsql \
    soap \
    xsl \
    xmlrpc \
    zip

docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
docker-php-ext-install -j$(nproc) gd

docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
docker-php-ext-install -j$(nproc) ldap

pecl install solr memcached redis apcu igbinary
docker-php-ext-enable solr memcached redis apcu igbinary

echo 'apc.enable_cli = On' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

# Keep our image size down..
pecl clear-cache
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
