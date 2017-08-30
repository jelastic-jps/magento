#!/bin/bash

WORK_DIR=/var/www/webroot/ROOT;
CUSTOM_WORK_DIR=$(find /tmp/magento-data -type f -name mage -printf '%h\n');
CUSTOM_DB_DUMP=$(find /tmp/magento-database -type f -name *.sql);

ORIG_LOCAL_XML=/tmp/local.xml;
CUSTOM_LOCAL_XML=${CUSTOM_WORK_DIR}/app/etc/local.xml;

MYSQL=`which mysql`;
SED=`which sed`;

cp $WORK_DIR/app/etc/local.xml /tmp;
cp $WORK_DIR/varnish-probe.php /tmp;

db_host=$(echo "cat /config/global/resources/default_setup/connection/host/text()" | xmllint --nocdata --shell $ORIG_LOCAL_XML | sed '1d;$d');
db_username=$(echo "cat /config/global/resources/default_setup/connection/username/text()" | xmllint --nocdata --shell $ORIG_LOCAL_XML | sed '1d;$d');
db_password=$(echo "cat /config/global/resources/default_setup/connection/password/text()" | xmllint --nocdata --shell $ORIG_LOCAL_XML | sed '1d;$d');
#dbname=$(echo "cat /config/global/resources/default_setup/connection/dbname/text()" | xmllint --nocdata --shell $ORIG_LOCAL_XML | sed '1d;$d');
custom_dbname=$(echo "cat /config/global/resources/default_setup/connection/dbname/text()" | xmllint --nocdata --shell $CUSTOM_LOCAL_XML | sed '1d;$d');
#custom_db_prefix=$(echo "cat /config/global/resources/default_setup/connection/db_prefix/text()" | xmllint --nocdata --shell $CUSTOM_LOCAL_XML | sed '1d;$d');
table_prefix_config=$(grep "table_prefix" $CUSTOM_LOCAL_XML | head -n1)

#### Local.xml
table_prefix_config=$(grep "table_prefix" $CUSTOM_LOCAL_XML | head -n1)
db_name_config=$(grep "dbname" $CUSTOM_LOCAL_XML | head -n1)
$SED -i "s|.*<table_prefix>.*|${table_prefix_config}|g" $ORIG_LOCAL_XML;
$SED -i "s|.*<dbname>.*|${db_name_config}|g" $ORIG_LOCAL_XML;

##### Deploy DB dump
$MYSQL -u$db_username -p$db_password -h$db_host -e "DROP DATABASE IF EXISTS ${custom_dbname}; CREATE DATABASE ${custom_dbname}";
$MYSQL -u$db_username -p$db_password -h$db_host ${custom_dbname} < $CUSTOM_DB_DUMP;

##### Deploy content ####
rm -rf $WORK_DIR/* $WORK_DIR/.ht*
mv $CUSTOM_WORK_DIR/* $CUSTOM_WORK_DIR/.ht* $WORK_DIR
cp $ORIG_LOCAL_XML $WORK_DIR/app/etc

#### Set permissions ####
chown nginx:nginx -hR $WORK_DIR
