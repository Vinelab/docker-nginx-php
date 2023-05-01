FROM php:7.4-fpm

LABEL maintainer="Abed Halawi <abed.halawi@vinelab.com>"

ENV php_conf /usr/local/etc/php/php.ini
ENV fpm_conf /usr/local/etc/php/php-fpm.conf

RUN apt-get update \
    && apt-get install -y autoconf pkg-config libssl-dev nginx supervisor cron \
    && docker-php-ext-install bcmath pcntl sockets

RUN mkdir /code

RUN useradd --no-create-home nginx

# tweak php-fpm config
COPY php.ini ${php_conf}
COPY nginx.conf /etc/nginx/nginx.conf
COPY php.conf /etc/nginx/php.conf
COPY host.conf /etc/nginx/conf.d/default.conf

VOLUME /code

COPY supervisord.conf /etc/supervisor/supervisord.conf

# Install git zip libpq and pcov for php coverage
RUN apt-get update \
    && apt-get install -y git zip libpq-dev \
    && pecl install pcov && docker-php-ext-enable pcov

# Install composer
COPY --from=composer/composer:latest-bin /composer /usr/local/bin/composer

WORKDIR /code

EXPOSE 443 80

CMD /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
