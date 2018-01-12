FROM php:7.1.13-fpm

MAINTAINER Abed Halawi <abed.halawi@vinelab.com>

ENV php_conf /usr/local/etc/php/php.ini
ENV fpm_conf /usr/local/etc/php/php-fpm.conf
ENV fpm_www_conf /usr/local/etc/php-fpm.d/www.conf

RUN apt-get update
RUN apt-get install -y autoconf pkg-config libssl-dev
RUN pecl install mongodb
RUN docker-php-ext-install bcmath
RUN echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini

RUN apt-get update
RUN apt-get install -y nginx supervisor cron

RUN docker-php-ext-install zip

RUN mkdir /code

RUN useradd --no-create-home nginx

# tweak php-fpm config
COPY php.ini ${php_conf}
COPY www.conf ${fpm_www_conf}
COPY nginx.conf /etc/nginx/nginx.conf
COPY php.conf /etc/nginx/php.conf
COPY host.conf /etc/nginx/conf.d/default.conf

# add cron runner script
COPY cron.sh /cron.sh

COPY supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /code

EXPOSE 443 80

CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
