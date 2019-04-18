FROM php:7.1.27-fpm-alpine3.8
MAINTAINER seven <82294148@qq.com>

RUN apk add --no-cache freetype libpng libjpeg-turbo \
freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j${NPROC} gd && docker-php-ext-enable gd && apk del \
  freetype-dev libpng-dev libjpeg-turbo-dev && \
  apk add gettext-dev  \
&& /usr/local/bin/docker-php-ext-install gettext pdo pdo_mysql opcache mysqli dba\
&& apk add --no-cache\
            autoconf \
            file \
            g++ \
            gcc \
            libc-dev \
            make \
            pkgconf \
            re2c \
            zlib-dev \
            libmemcached-dev && \
        cd /tmp && \
        wget https://github.com/php-memcached-dev/php-memcached/archive/php7.zip && \
        unzip php7.zip && \
        cd php-memcached-php7 && \
        phpize || return 1 && \
        ./configure --prefix=/usr --disable-memcached-sasl --with-php-config=php-config || return 1 && \
        make || return 1 && \
        make INSTALL_ROOT="" install || return 1 && \
        install -d "/etc/php7/conf.d" || return 1 && \
        echo "extension=memcached.so" > /etc/php7/conf.d/20_memcached.ini && \
        cd /tmp && rm -rf php-memcached-php7 && rm php7.zip && \
        docker-php-ext-enable memcached &&\
cd /tmp \
        && wget https://github.com/igbinary/igbinary/archive/2.0.4.zip \
        && unzip 2.0.4.zip && cd igbinary-2.0.4 \
        && phpize && ./configure --with-php-config=php-config \
        && make && make install \
        && echo extension=igbinary.so >> /etc/php7/conf.d/01_igbinary.ini &&\
        wget https://github.com/phpredis/phpredis/archive/3.1.2.zip \
        && unzip 3.1.2.zip && cd phpredis-3.1.2 \
        && phpize && ./configure --enable-redis-igbinary --with-php-config=php-config \
        && make && make install \
        && echo extension=redis.so >> /etc/php7/conf.d/01_redis.ini && \
        docker-php-ext-enable igbinary redis && apk del autoconf \
                                                                    file \
                                                                    g++ \
                                                                    gcc \
                                                                    libc-dev \
                                                                    make \
                                                                    pkgconf \
                                                                    re2c \
                                                                    zlib-dev