#!/bin/bash

WORK_DIR=/var/www/webroot/ROOT;
MG="php ${WORK_DIR}/bin/magento"
CUSTOM_DATA_DIR=$(find /tmp/magento-data -type f -name mage -printf '%h\n');
CUSTOM_DB_DUMP=$(find /tmp/magento-database -type f -name *.sql);

MYSQL=`which mysql`;
SED=`which sed`;

cp $WORK_DIR/app/etc/env.php /tmp;
cp $WORK_DIR/pub/health_check.php /tmp;

#### DB connections
db_host=$(cat $WORK_DIR/app/etc/env.php | grep -A 10 "'db' => " | grep -Po "(?<='host' => ).*(?=,)")
db_username=$(cat $WORK_DIR/app/etc/env.php | grep -A 10 "'db' => " | grep -Po "(?<='username' => ).*(?=,)")
db_password=$(cat $WORK_DIR/app/etc/env.php | grep -A 10 "'db' => " | grep -Po "(?<='password' => ).*(?=,)")
db_name=$(cat $WORK_DIR/app/etc/env.php | grep -A 10 "'db' => " | grep -Po "(?<='dbname' => ).*(?=,)")

#### Basic config
web_unsecure_base_url=$(${MG} config:show web/unsecure/base_url)
web_secure_base_url=$(${MG} config:show web_secure_base_url)

##### Move content ####
rm -rf $WORK_DIR/* $WORK_DIR/.ht*
find $CUSTOM_DATA_DIR -maxdepth 1 -mindepth 1 -exec mv -t $WORK_DIR {} +;

##### Deploy DB dump #######
MYSQL_ARG="-u$db_username -p$db_password -h$db_host"
$MYSQL $MYSQL_ARG -e "DROP DATABASE IF EXISTS ${db_name}; CREATE DATABASE ${db_name}";
$MYSQL $MYSQL_ARG $db_name < $CUSTOM_DB_DUMP;

#### Recovery config
cp /tmp/env.php $WORK_DIR/app/etc
cp /tmp/health_check.php $WORK_DIR $WORK_DIR/pub
${MG} config:set web/unsecure/base_url ${web_unsecure_base_url} &>> /var/log/run.log;
${MG} config:set web/secure/base_url ${web_secure_base_url} &>> /var/log/run.log;

#### Set permissions ####
find $WORK_DIR -type f -exec chmod 644 {} \;
find $WORK_DIR -type d -exec chmod 755 {} \;
chmod -R 777 $WORK_DIR/media $WORK_DIR/var $WORK_DIR/app/etc

#### Cache cleaning and context reindexing
rm -rf $WORK_DIR/var/{cache,report,session, page_cache}
${MG} indexer:reindex &>> /var/log/run.log;
echo 'Magento data was migrated' &>> /var/log/run.log;
#####
