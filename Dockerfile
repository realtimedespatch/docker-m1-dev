FROM php:7.2-cli-alpine3.9

ARG MAGENTO_VERSION=1.9.4.1
ARG ORDERFLOW_VERSION=2.0.0

ENV MAGENTO_VERSION=$MAGENTO_VERSION
ENV ORDERFLOW_VERSION=$ORDERFLOW_VERSION

RUN apk add --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        icu-dev \
        libxml2-dev \
        libxslt-dev \
        && docker-php-ext-install zip bcmath pdo_mysql intl soap xsl \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-install gd

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN mkdir /assets && \
    wget -O /assets/magento.tar.gz https://github.com/OpenMage/magento-mirror/archive/$MAGENTO_VERSION.tar.gz && \
    wget -O /assets/orderflow.tar.gz https://github.com/realtimedespatch/magento-orderflow/archive/$ORDERFLOW_VERSION.tar.gz

COPY assets/install.sh /install.sh
RUN chmod +x /install.sh

COPY sampledata/magento-sample-data-1.9.1.0.tar.gz /assets/sampledata-1.9.1.0.tar.gz
COPY sampledata/magento-sample-data-1.9.2.4.tar.gz /assets/sampledata-1.9.2.4.tar.gz
COPY assets/ /assets/

WORKDIR /app
