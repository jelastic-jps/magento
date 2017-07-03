#!/bin/bash

MYSQL=`which mysql`
SED=`which sed`
DB_USER=$1
DB_PASS=$2
DB_HOST=$3
DB_NAME=$4
MG_ADMIN=$5
MG_PATH=$6
ENV_URL=$7
USER_EMAIL=$8

#$MYSQL -u${DB_USER} -p${DB_PASS} -h ${DB_HOST} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"

php ${MG_PATH}/bin/magento admin:user:create \
--admin-user=admin \
--admin-password=${MG_ADMIN} \
--admin-firstname=Admin \
--admin-lastname=AdminLast 
--admin-email=${USER_EMAIL}"

#php ${MG_PATH}/bin/magento setup:install -s \
#--backend-frontname=admin \
#--db-host=${DB_HOST} \
#--db-name=${DB_NAME} \
#--db-user=${DB_USER} \
#--db-password=${DB_PASS} \
#--base-url=${ENV_URL} \
#--admin-firstname=Admin \
#--admin-lastname=AdminLast \
#--admin-email=${USER_EMAIL} \
#--admin-user=admin \
#--admin-password=${MG_ADMIN};

#$SED -i 's|getBlock(\$callback\[0\])->\$callback\[1\]|getBlock(\$callback\[0\])->{\$callback\[1\]}|g' ${MG_PATH}/app/code/core/Mage/Core/Model/Layout.php;
#$SED -i 's|false|true|g' ${MG_PATH}/app/etc/modules/Cm_RedisSession.xml;
rm -rf ${MG_PATH}/var/*;
chown nginx:nginx ${MG_PATH}/* -R;
