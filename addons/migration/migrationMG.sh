#!/bin/bash

WORK_DIR=/var/www/webroot/ROOT;

CUSTOM_DATA_DIR=$(find /tmp/magento-data -type f -name mage -printf '%h\n');
if [[ ! -d $CUSTOM_DATA_DIR ]] ; then
	echo 'ERROR: /tmp/magento-data: Data content is incorrect or the magento version isnt 1.9.x'
	exit 1
fi

CUSTOM_DB_DUMP=$(find /tmp/magento-database -type f -name *.sql);

if [[ ! -f $CUSTOM_DB_DUMP ]] ; then
	echo 'ERROR: /tmp/magento-database: SQL with DB dump not found'
	exit 1
fi

ORIG_LOCAL_XML=/tmp/local.xml;
CUSTOM_LOCAL_XML=${CUSTOM_DATA_DIR}/app/etc/local.xml;

if [[ ! -f $CUSTOM_LOCAL_XML ]] ; then
	echo "ERROR: ${CUSTOM_LOCAL_XML}: Config local.xml not found"
	exit 1
fi

MYSQL=`which mysql`;

SED=`which sed`;

cp $WORK_DIR/app/etc/local.xml /tmp;
cp $WORK_DIR/varnish-probe.php /tmp;

db_host=$(echo "cat /config/global/resources/default_setup/connection/host/text()" | xmllint --nocdata --shell $ORIG_LOCAL_XML | sed '1d;$d');
db_username=$(echo "cat /config/global/resources/default_setup/connection/username/text()" | xmllint --nocdata --shell $ORIG_LOCAL_XML | sed '1d;$d');
db_password=$(echo "cat /config/global/resources/default_setup/connection/password/text()" | xmllint --nocdata --shell $ORIG_LOCAL_XML | sed '1d;$d');
dbname=$(echo "cat /config/global/resources/default_setup/connection/dbname/text()" | xmllint --nocdata --shell $ORIG_LOCAL_XML | sed '1d;$d');
custom_dbname=$(echo "cat /config/global/resources/default_setup/connection/dbname/text()" | xmllint --nocdata --shell $CUSTOM_LOCAL_XML | sed '1d;$d');
db_prefix=$(echo "cat /config/global/resources/db/table_prefix/text()" | xmllint --nocdata --shell $ORIG_LOCAL_XML | sed '1d;$d');
custom_db_prefix=$(echo "cat /config/global/resources/db/table_prefix/text()" | xmllint --nocdata --shell $CUSTOM_LOCAL_XML | sed '1d;$d');

#### Local.xml
table_prefix_config=$(grep "table_prefix" $CUSTOM_LOCAL_XML | head -n1)
db_name_config=$(grep "dbname" $CUSTOM_LOCAL_XML | head -n1)
$SED -i "s|.*<table_prefix>.*|${table_prefix_config}|g" $ORIG_LOCAL_XML;
$SED -i "s|.*<dbname>.*|${db_name_config}|g" $ORIG_LOCAL_XML;

##### Deploy and configure DB dump #######

MYSQL_ARG="-u$db_username -p$db_password -h$db_host"
web_unsecure_base_url=$($MYSQL $MYSQL_ARG $dbname -se "SELECT value FROM ${db_prefix}core_config_data WHERE path='web/unsecure/base_url'");
web_secure_base_url=$($MYSQL $MYSQL_ARG $dbname -se "SELECT value FROM ${db_prefix}core_config_data WHERE path='web/secure/base_url'");
$MYSQL $MYSQL_ARG -e "DROP DATABASE IF EXISTS ${custom_dbname}; CREATE DATABASE ${custom_dbname}";
$MYSQL $MYSQL_ARG $custom_dbname < $CUSTOM_DB_DUMP;
$MYSQL $MYSQL_ARG $custom_dbname -se "UPDATE ${custom_db_prefix}core_config_data SET value='${web_unsecure_base_url}' WHERE path='web/unsecure/base_url'";
$MYSQL $MYSQL_ARG $custom_dbname -se "UPDATE ${custom_db_prefix}core_config_data SET value='${web_secure_base_url}' WHERE path='web/secure/base_url'";

##### Move content ####
rm -rf $WORK_DIR/* $WORK_DIR/.ht*
find $CUSTOM_DATA_DIR -maxdepth 1 -mindepth 1 -exec mv -t $WORK_DIR {} +;

cp $ORIG_LOCAL_XML $WORK_DIR/app/etc
cp /tmp/varnish-probe.php $WORK_DIR

sed -i 's|getBlock(\$callback\[0\])->\$callback\[1\]|getBlock(\$callback\[0\])->{\$callback\[1\]}|g' $WORK_DIR/app/code/core/Mage/Core/Model/Layout.php;

#### Set permissions ####
find $WORK_DIR -type f -exec chmod 644 {} \;
find $WORK_DIR -type d -exec chmod 755 {} \;
chmod -R 777 $WORK_DIR/media $WORK_DIR/var $WORK_DIR/app/etc

#### Cache cleaning and context reindexing
rm -rf $WORK_DIR/var/{cache,report,session}
php -f $WORK_DIR/shell/indexer.php reindexall
chown nginx:nginx -hR $WORK_DIR
echo 'Magento data was migrated'
#####
