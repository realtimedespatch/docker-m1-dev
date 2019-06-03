FROM php:7.2-cli-alpine3.9

ENV MAGENTO_VERSION=1.9.4.1
ENV ORDERFLOW_VERSION=2.0.0

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN mkdir /assets && \
    wget -O /assets/magento.tar.gz https://github.com/OpenMage/magento-mirror/archive/$MAGENTO_VERSION.tar.gz && \
    wget -O /assets/orderflow.tar.gz https://github.com/realtimedespatch/magento-orderflow/archive/$ORDERFLOW_VERSION.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY install.sh /install.sh
RUN chmod +x /install.sh

COPY docker-compose.yml /assets

#ENTRYPOINT /entrypoint.sh
WORKDIR /app
