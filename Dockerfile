FROM nginx:alpine

MAINTAINER Abed Halawi <abed.halawi@vinelab.com>

ENV php_conf /etc/php5/php.ini
ENV fpm_conf /etc/php5/php-fpm.conf

RUN apk add --no-cache bash \
    php5-fpm \
    php5-pdo \
    php5-pdo_mysql \
    php5-mysql \
    php5-mysqli \
    php5-mcrypt \
    php5-ctype \
    php5-zlib \
    php5-gd \
    php5-intl \
    php5-memcache \
    php5-sqlite3 \
    php5-pgsql \
    php5-xml \
    php5-xsl \
    php5-curl \
    php5-openssl \
    php5-iconv \
    php5-json \
    php5-phar \
    php5-soap \
    php5-dom \
    php5-zip \
        linux-headers \
        libffi-dev

RUN apk add --no-cache supervisor

RUN apk del linux-headers libffi-dev

RUN mkdir -p /etc/nginx && mkdir /code

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" ${php_conf} && \
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" ${php_conf} && \
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" ${php_conf} && \
sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" ${php_conf} && \
sed -i -e "s/expose_php = On/expose_php = Off/g" ${php_conf} && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" ${fpm_conf} && \
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" ${fpm_conf} && \
sed -i -e "s/pm.max_children = 4/pm.max_children = 4/g" ${fpm_conf} && \
sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" ${fpm_conf} && \
sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" ${fpm_conf} && \
sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" ${fpm_conf} && \
sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" ${fpm_conf} && \
sed -i -e "s/user = nobody/user = nginx/g" ${fpm_conf} && \
sed -i -e "s/group = nobody/group = nginx/g" ${fpm_conf} && \
sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g" ${fpm_conf} && \
sed -i -e "s/;listen.owner = nobody/listen.owner = nginx/g" ${fpm_conf} && \
sed -i -e "s/;listen.group = nobody/listen.group = nginx/g" ${fpm_conf} && \
sed -i -e "s/^;clear_env = no$/clear_env = no/" ${fpm_conf} &&\
ln -s /etc/php5/php.ini /etc/php5/conf.d/php.ini && \
find /etc/php5/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

COPY nginx.conf /etc/nginx/nginx.conf
COPY php.conf /etc/nginx/php.conf
COPY host.conf /etc/nginx/conf.d/default.conf

VOLUME /code

COPY supervisord.conf /etc/supervisord.conf

EXPOSE 443 80

CMD /usr/bin/supervisord -n -c /etc/supervisord.conf
