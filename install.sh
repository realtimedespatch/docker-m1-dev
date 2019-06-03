#!/bin/sh

echo "########################################################################"
echo "# Installing Magento CE v$MAGENTO_VERSION with SixBySix_RealTimeDespatch v$ORDERFLOW_VERSION #"
echo "########################################################################"

if [ ! -d "/app" ]; then
  echo "/app does not exit"
  exit 1
fi

if [ "$(ls -A /app)" ]; then
  echo "Extracting base magento codebase..."
  tar xzf /assets/magento.tar.gz --strip-components=1 -C /app
fi

echo "Extracting orderflow extension..."
tar xzf /assets/orderflow.tar.gz --strip-components=1 -C /app

echo "Installing composer dependencies..."
/usr/bin/composer install

echo "Copying docker-compose config to codebase..."
cp /assets/docker-compose.yml /app