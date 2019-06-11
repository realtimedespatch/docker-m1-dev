#!/bin/sh

echo "########################################################################"
echo "# Installing Magento CE v$MAGENTO_VERSION with SixBySix_RealTimeDespatch:$ORDERFLOW_VERSION #"
echo "########################################################################"

if [ ! -d "/app" ]; then
  echo "/app does not exit"
  exit 1
fi

cd /app

# Gather env details
COMPOSE_PROJECT_NAME="of${ORDERFLOW_VERSION}m${MAGENTO_VERSION}"
NGINX_PORT=80
DB_PORT=3066
if [ -f ".env" ]; then
  # override defaults with existing config
  source .env
else
  MYSQL_DATABASE="magento"
  MYSQL_USER="magento"
  MYSQL_PASSWORD="918a9b2f3384"
  MYSQL_ROOT_PASSWORD="70c6830775bb"
fi

project_name=$COMPOSE_PROJECT_NAME
nginx_port=$NGINX_PORT
db_port=$DB_PORT

echo "Project name ($project_name):"
read project_name || project_name="$COMPOSE_PROJECT_NAME"

echo "Nginx local port? ($nginx_port)"
read nginx_port || nginx_port="$NGINX_PORT"

echo "MySQL local port? ($db_port)"
read db_port || db_port="$DB_PORT"

# Start extracting / copying assets to the codebase
echo "Extracting base magento codebase..."
tar xzf /assets/magento.tar.gz --strip-components=1 -C /app

echo "Choosing correct sample data..."
if [ "`echo $MAGENTO_VERSION | sed 's/\./0/g'`" -ge "1090204" ]; then
  sample_data=/assets/sampledata-1.9.2.4.tar.gz
  sql_file=magento_sample_data_for_1.9.2.4.sql
else
  sample_data=/assets/sampledata-1.9.1.0.tar.gz
  sql_file=magento_sample_data_for_1.9.1.0.sql
fi

echo "Extract sample data ($sample_data)..."
tar xzf $sample_data --strip-components=1 -C /app
mv /app/$sql_file /app/sample_data.sql

echo "Extract orderflow extension..."
tar xzf /assets/orderflow.tar.gz --strip-components=1 -C /app

echo "Installing composer dependencies..."
/usr/bin/composer install --ignore-platform-reqs

echo "Provisioning docker volumes..."
mkdir -p docker
mkdir -p docker/db/data
mkdir -p docker/nginx/
mkdir -p docker/php/

echo "Writing docker .env"
# hardcoded username / password doesn't matter here as it's for local use
cat > .env << EOF
COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME

NGINX_PORT=$NGINX_PORT
DB_PORT=$DB_PORT

MYSQL_DATABASE=$MYSQL_DATABASE
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
EOF

echo "Copying docker-compose config to codebase..."
cp /assets/docker-compose.yml .

echo "Copy php container Dockerfile..."
cp /assets/php/Dockerfile ./docker/php

echo "Copy nginx vhost..."
cp /assets/nginx/default.conf ./docker/nginx

cp -rp /assets/bin .

echo "Codebase directory permissions..."
# @todo to do?

echo "Write env file..."

cat > app/etc/local.xml << EOF
<config>
    <global>
        <install>
            <date><![CDATA[`date`]]></date>
        </install>
        <crypt>
            <key><![CDATA[`date +%s | sha256sum | base64 | head -c 32 ;`]]></key>
        </crypt>
        <disable_local_modules><![CDATA[false]]></disable_local_modules>
        <resources>
            <db>
                <table_prefix><![CDATA[]]></table_prefix>
            </db>
            <default_setup>
                <connection>
                    <host><![CDATA[db]]></host>
                    <username><![CDATA[$MYSQL_USER]]></username>
                    <password><![CDATA[$MYSQL_PASSWORD]]></password>
                    <dbname><![CDATA[$MYSQL_DATABASE]]></dbname>
                    <initStatements><![CDATA[SET NAMES utf8]]></initStatements>
                    <model><![CDATA[mysql4]]></model>
                    <type><![CDATA[pdo_mysql]]></type>
                    <pdoType><![CDATA[]]></pdoType>
                    <active>1</active>
                </connection>
            </default_setup>
        </resources>
        <session_save><![CDATA[files]]></session_save>
    </global>
    <admin>
        <routers>
            <adminhtml>
                <args>
                    <frontName><![CDATA[admin]]></frontName>
                </args>
            </adminhtml>
        </routers>
    </admin>
</config>
EOF

# switch on maintenance mode to prevent user generating db
touch maintenance.flag