#!/bin/bash

WORK_DIR=/var/www/webroot/ROOT;
CUSTOM_DATA_DIR=$(find /tmp/magento-data -type f -name mage -printf '%h\n');
CUSTOM_DB_DUMP=$(find /tmp/magento-database -type f -name *.sql);

ORIG_LOCAL_XML=/tmp/local.xml;
CUSTOM_LOCAL_XML=${CUSTOM_DATA_DIR}/app/etc/local.xml;

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
#[ ! -z "$db_prefix" ] && db_prefix=${db_prefix}_;
custom_db_prefix=$(echo "cat /config/global/resources/db/table_prefix/text()" | xmllint --nocdata --shell $CUSTOM_LOCAL_XML | sed '1d;$d');
#[ ! -z "$custom_db_prefix" ] && custom_db_prefix=${custom_db_prefix}_;
#table_prefix_config=$(grep "table_prefix" $CUSTOM_LOCAL_XML | head -n1)

#### Local.xml
table_prefix_config=$(grep "table_prefix" $CUSTOM_LOCAL_XML | head -n1)
db_name_config=$(grep "dbname" $CUSTOM_LOCAL_XML | head -n1)
$SED -i "s|.*<table_prefix>.*|${table_prefix_config}|g" $ORIG_LOCAL_XML;
$SED -i "s|.*<dbname>.*|${db_name_config}|g" $ORIG_LOCAL_XML;

##### Deploy and configure DB dump #######

web_unsecure_base_url=$($MYSQL -u$db_username -p$db_password -h$db_host $dbname -se "SELECT value FROM ${db_prefix}core_config_data WHERE path='web/unsecure/base_url'");
web_secure_base_url=$($MYSQL -u$db_username -p$db_password -h$db_host $dbname -se "SELECT value FROM ${db_prefix}core_config_data WHERE path='web/secure/base_url'");
$MYSQL -u$db_username -p$db_password -h$db_host -e "DROP DATABASE IF EXISTS ${custom_dbname}; CREATE DATABASE ${custom_dbname}";
$MYSQL -u$db_username -p$db_password -h$db_host $custom_dbname < $CUSTOM_DB_DUMP;
$MYSQL -u$db_username -p$db_password -h$db_host $custom_dbname -se "UPDATE ${custom_db_prefix}core_config_data SET value='${web_unsecure_base_url}' WHERE path='web/unsecure/base_url'";
$MYSQL -u$db_username -p$db_password -h$db_host $custom_dbname -se "UPDATE ${custom_db_prefix}core_config_data SET value='${web_secure_base_url}' WHERE path='web/secure/base_url'";

##### Deploy content ####
rm -rf $WORK_DIR/* $WORK_DIR/.ht*
mv $CUSTOM_DATA_DIR/* $CUSTOM_DATA_DIR/.ht* $WORK_DIR
cp $ORIG_LOCAL_XML $WORK_DIR/app/etc
cp /tmp/varnish-probe.php $WORK_DIR

#### Set permissions ####
chown nginx:nginx -hR $WORK_DIR
