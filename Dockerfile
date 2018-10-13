FROM php:7.1.13-fpm

MAINTAINER Abed Halawi <abed.halawi@vinelab.com>

ENV FILEBEAT_VERSION 6.4.2
ENV php_conf /usr/local/etc/php/php.ini
ENV fpm_conf /usr/local/etc/php/php-fpm.conf
ENV fpm_conf_dir /usr/local/etc/php-fpm.d/

RUN apt-get update
RUN apt-get install -y autoconf pkg-config libssl-dev
RUN pecl install mongodb
RUN docker-php-ext-install bcmath
RUN echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini

# install filebeat and NGINX
RUN curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-amd64.deb
RUN dpkg -i filebeat-${FILEBEAT_VERSION}-amd64.deb
RUN filebeat modules enable nginx

RUN apt-get update
RUN apt-get install -y nginx supervisor cron

RUN docker-php-ext-install zip

RUN mkdir /code

RUN useradd --no-create-home nginx

# tweak php-fpm config
COPY php/php.ini ${php_conf}
COPY php/www.conf.default ${fpm_conf_dir}/www.conf
COPY php/pools/pool-1.conf ${fpm_conf_dir}/pool-1.conf
COPY php/pools/pool-2.conf ${fpm_conf_dir}/pool-2.conf
COPY php/pools/pool-3.conf ${fpm_conf_dir}/pool-3.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/php.conf /etc/nginx/php.conf
COPY nginx/host.conf /etc/nginx/conf.d/default.conf
COPY filebeat/filebeat.yml /etc/filebeat/filebeat.yml
COPY filebeat/nginx.yml /etc/filebeat/modules.d/nginx.yml

# add cron runner script
COPY cron.sh /cron.sh

COPY supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /code

EXPOSE 443 80

CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
