#!/bin/bash

[ -d /etc/php.d ] || mkdir -p /etc/php.d

echo "clear_env = no" >> /etc/php-fpm.conf;
echo "security.limit_extensions = .php .php3 .php4 .php5 .php7" >> /etc/php-fpm.conf;

## - Main conf
sed -i 's|; Jelastic autoconfiguration mark||g' /etc/php-fpm.conf;

sed -i 's|pm = dynamic|pm = ondemand|g' /etc/php-fpm.conf;
sed -i 's|pm.max_children = 50|pm.max_children = 16\npm.process_idle_timeout = 60s|g' /etc/php-fpm.conf;

echo "always_populate_raw_post_data = -1" >> /etc/php.ini;

sed -i 's|memory_limit = 128M|memory_limit = 512M|g' /etc/php.ini;

## - The requested PHP extension ext-gd * is missing from your system. Install or enable PHP's gd extension.
sed -i 's|.*extension=gd.so|extension=gd.so|g' /etc/php.ini;

## - The requested PHP extension ext-intl * is missing from your system. Install or enable PHP's intl extension.
sed -i 's|;extension=intl.so|extension=intl.so|g' /etc/php.ini;

## - The requested PHP extension ext-xsl * is missing from your system. Install or enable PHP's xsl extension.
sed -i 's|.*extension=xsl.so|extension=xsl.so|g' /etc/php.ini;
