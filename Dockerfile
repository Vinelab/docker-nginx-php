FROM php:7.1.27-fpm-stretch

LABEL maintainer="Abed Halawi <abed.halawi@vinelab.com>"

ENV php_conf /usr/local/etc/php/php.ini
ENV fpm_conf /usr/local/etc/php/php-fpm.conf
ENV fpm_conf_dir /usr/local/etc/php-fpm.d/

RUN apt-get update \
    && apt-get install -y autoconf pkg-config libssl-dev

RUN docker-php-ext-install bcmath
RUN docker-php-ext-install sockets

RUN pecl install mongodb-1.2.2  \
    && docker-php-ext-enable mongodb

RUN apt-get update \
    && apt-get install -y libzip-dev zip \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install zip

RUN apt-get update \
    && apt-get install -y nginx supervisor cron

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

# add cron runner script
COPY cron.sh /cron.sh

COPY supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /code

EXPOSE 443 80

CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
