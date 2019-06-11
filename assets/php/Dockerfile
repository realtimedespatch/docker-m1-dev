FROM magento/magento-cloud-docker-php:7.2-fpm

RUN apt-get install -y mysql-client

# install n98-magerun.phar
RUN cd /tmp/ && curl https://files.magerun.net/n98-magerun.phar > /usr/local/bin/n98 && chmod +x /usr/local/bin/n98

# install https://github.com/punkstar/mageconfigsync/
RUN curl -L https://github.com/punkstar/mageconfigsync/releases/download/0.5.0-beta.1/mageconfigsync-0.5.0-beta.1.phar > /usr/local/bin/mageconfigsync
RUN chmod +x /usr/local/bin/mageconfigsync